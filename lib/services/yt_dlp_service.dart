import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'package:mp3box/properties.dart';

class YtDlpService {
  static final YtDlpService _instance = YtDlpService._internal();
  factory YtDlpService() => _instance;
  YtDlpService._internal();

  String? _binDir;
  String? _ytDlpPath;
  String? _ffmpegPath;
  
  final List<String> _logs = [];

  List<String> get logs => List.unmodifiable(_logs);
  void clearLogs() => _logs.clear();
  
  void _addLog(String message) {
    debugPrint('MP3Box: $message');
    _logs.add('[${DateTime.now().toLocal().toString().split('.').first}] $message');
  }

  Future<void> init() async {
    final appDir = await getApplicationSupportDirectory();
    _binDir = appDir.path;
    _ytDlpPath = p.join(_binDir!, 'yt-dlp.exe');
    _ffmpegPath = p.join(_binDir!, 'ffmpeg.exe');
  }

  bool get isReady => _ytDlpPath != null && 
                     File(_ytDlpPath!).existsSync() && 
                     File(_ffmpegPath!).existsSync();

  Future<void> ensureBinaries(Function(String, double) onProgress) async {
    await _ensureYtDlp((p) => onProgress('yt-dlp', p));
    await _ensureFfmpeg((p) => onProgress('ffmpeg', p));
    
    // Auto-update yt-dlp if it already existed but might be old
    if (File(_ytDlpPath!).existsSync()) {
      await updateEngine((status) => onProgress(status, 1.0));
    }
  }

  Future<void> updateEngine(Function(String) onStatus) async {
    if (!isReady) return;
    _addLog('Checking for yt-dlp updates...');
    onStatus('Checking for updates...');
    
    try {
      final process = await Process.run(_ytDlpPath!, ['-U']);
      _addLog(process.stdout.toString());
      if (process.exitCode == 0) {
        _addLog('yt-dlp is up to date or updated.');
        onStatus('Engine is up to date.');
      } else {
        _addLog('Update failed with exit code ${process.exitCode}');
        onStatus('Update check failed.');
      }
    } catch (e) {
      _addLog('Update error: $e');
      onStatus('Update error.');
    }
  }

  Future<void> _ensureYtDlp(Function(double) onProgress) async {
    if (File(_ytDlpPath!).existsSync()) return;

    _addLog('Downloading yt-dlp...');
    final url = Uri.parse(AppProperties.ytDlpDownloadUrl);
    await _downloadFile(url, _ytDlpPath!, onProgress);
  }

  Future<void> _ensureFfmpeg(Function(double) onProgress) async {
    if (File(_ffmpegPath!).existsSync()) return;

    _addLog('Downloading FFmpeg (required for MP3 conversion)...');
    // Using a reliable static build link for Windows
    final url = Uri.parse(AppProperties.ffmpegDownloadUrl);
    
    final tempZip = p.join(_binDir!, 'ffmpeg.zip');
    await _downloadFile(url, tempZip, onProgress);

    _addLog('Extracting FFmpeg...');
    final bytes = await File(tempZip).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      if (file.name.endsWith('ffmpeg.exe') || file.name.endsWith('ffprobe.exe')) {
        final filename = p.basename(file.name);
        final data = file.content as List<int>;
        File(p.join(_binDir!, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        _addLog('Extracted $filename');
      }
    }

    // Cleanup
    await File(tempZip).delete();
    _addLog('FFmpeg setup complete.');
  }

  Future<void> _downloadFile(Uri url, String savePath, Function(double) onProgress) async {
    final client = http.Client();
    final request = http.Request('GET', url);
    final response = await client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to download: ${response.statusCode}');
    }

    final total = response.contentLength ?? 0;
    int downloaded = 0;
    final file = File(savePath);
    final sink = file.openWrite();

    await for (final chunk in response.stream) {
      downloaded += chunk.length;
      if (total > 0) {
        onProgress(downloaded / total);
      }
      sink.add(chunk);
    }

  await sink.close();
    client.close();
  }

  Future<List<Map<String, String>>> search(String query, {int limit = 5}) async {
    if (!isReady) return [];

    _addLog('Searching for: $query');
    final args = [
      'ytsearch$limit:$query',
      '--get-title',
      '--get-id',
      '--get-duration',
      '--get-thumbnail',
      '--flat-playlist',
    ];

    try {
      final process = await Process.run(_ytDlpPath!, args);
      if (process.exitCode != 0) return [];

      final lines = process.stdout.toString().split('\n').where((l) => l.trim().isNotEmpty).toList();
      final results = <Map<String, String>>[];
      
      // yt-dlp outputs title, id, duration, thumbnail sequentially for each result
      for (int i = 0; i + 3 < lines.length; i += 4) {
        results.add({
          'title': lines[i],
          'id': lines[i + 1],
          'duration': lines[i + 2],
          'thumbnail': lines[i + 3],
          'url': 'https://www.youtube.com/watch?v=${lines[i + 1]}',
        });
      }
      return results;
    } catch (e) {
      _addLog('Search error: $e');
      return [];
    }
  }

  Future<void> downloadMp3(
    String url, 
    String outputPath, 
    Function(String) onStatus,
    Function(double) onProgress, {
    String bitrate = '192K',
    bool embedLyrics = false,
  }) async {
    if (!isReady) throw Exception('Engine binaries are missing');

    final args = [
      url,
      '--ffmpeg-location', _binDir!,
      '-x', 
      '--audio-format', 'mp3',
      '--audio-quality', bitrate,
      '--embed-metadata',
      '--embed-thumbnail',
      if (embedLyrics) ...[
        '--write-subs',
        '--write-auto-subs',
        '--all-subs',
        '--convert-subs', 'srt',
        '--parse-metadata', 'description:(?P<lyrics>(?s).+)',
      ],
      '-o', outputPath,
      '--newline',
    ];

    _addLog('Starting conversion: $url');
    final process = await Process.start(_ytDlpPath!, args);

    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      line = line.trim();
      if (line.isNotEmpty) {
        _addLog(line);
        onStatus(line);
        final match = RegExp(r'\[download\]\s+(\d+\.\d+)%').firstMatch(line);
        if (match != null) {
          onProgress(double.parse(match.group(1)!) / 100.0);
        }
      }
    });

    process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((error) {
      error = error.trim();
      if (error.isNotEmpty) {
        _addLog('ERROR: $error');
        onStatus('Error: $error');
      }
    });

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      await saveLogsToFile();
      throw Exception('yt-dlp exited with code $exitCode');
    }
  }

  Future<String> saveLogsToFile() async {
    if (_binDir == null) return '';
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
    final logFile = File(p.join(_binDir!, 'error_$timestamp.log'));
    await logFile.writeAsString(_logs.join('\n'));
    return logFile.path;
  }
}
