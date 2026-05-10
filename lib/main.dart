import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mp3box/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:mp3box/services/yt_dlp_service.dart';
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('ko'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ytDlp = YtDlpService();
  await ytDlp.init();
  runApp(const MP3BoxApp());
}

class MP3BoxApp extends StatelessWidget {
  const MP3BoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'MP3Box',
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ko'),
          ],
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF0000),
              brightness: Brightness.dark,
              primary: const Color(0xFFFF0000),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F0F0F),
          ),
          home: const ConversionPage(),
        );
      },
    );
  }
}

class ConversionPage extends StatefulWidget {
  const ConversionPage({super.key});

  @override
  State<ConversionPage> createState() => _ConversionPageState();
}

class _ConversionPageState extends State<ConversionPage> {
  final TextEditingController _urlController = TextEditingController();
  final YtDlpService _ytDlp = YtDlpService();
  
  bool _isDownloading = false;
  bool _isSettingUp = false;
  double _progress = 0.0;
  String _status = ''; // Will be initialized in didChangeDependencies

  String _selectedBitrate = '192K';
  final List<String> _bitrates = ['128K', '192K', '320K'];
  String _downloadDirectory = '';

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;
  bool _embedLyrics = false;
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_status.isEmpty) {
      if (!_ytDlp.isReady) {
        _status = AppLocalizations.of(context)!.statusSetupRequired;
      } else {
        _status = AppLocalizations.of(context)!.statusPasteUrl;
        _checkUpdate();
      }
    }
    _initDefaultDirectory();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkUpdate() async {
    await _ytDlp.updateEngine((status) {
      if (mounted) setState(() => _status = status);
    });
  }

  Future<void> _initDefaultDirectory() async {
    try {
      String? musicPath;

      if (Platform.isWindows) {
        // PowerShell 명령어를 통해 시스템에 등록된 정확한 '음악' 폴더 경로 추출
        // 사용자가 D:\ 등으로 위치를 옮겼어도 정확한 경로를 반환합니다.
        final result = await Process.run('powershell', [
          '-Command',
          '[Environment]::GetFolderPath("MyMusic")'
        ]);

        if (result.exitCode == 0) {
          musicPath = result.stdout.toString().trim();
        }
      }

      if (musicPath != null && musicPath.isNotEmpty) {
        setState(() {
          _downloadDirectory = p.join(musicPath!, 'MP3Box');
        });
      } else {
        // Fallback
        final dir = await getDownloadsDirectory();
        if (dir != null) {
          setState(() {
            _downloadDirectory = p.join(dir.path, 'MP3Box');
          });
        }
      }
    } catch (e) {
      setState(() {
        _downloadDirectory = 'C:\\MP3Box';
      });
    }
  }

  Future<void> _pickDirectory() async {
    String? selectedDirectory = await FilePicker.getDirectoryPath();
    if (!mounted) return;
    if (selectedDirectory != null) {
      setState(() {
        _downloadDirectory = selectedDirectory;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    if (!_ytDlp.isReady) {
      await _setupEngine();
      if (!_ytDlp.isReady) return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final results = await _ytDlp.search(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      _showError('Search failed: $e');
    }
  }

  void _onResultSelected(Map<String, String> result) {
    setState(() {
      _urlController.text = result['url']!;
    });
    // Scroll back to top or just start conversion
    _convertVideo();
  }

  Future<void> _setupEngine() async {
    setState(() {
      _isSettingUp = true;
      _status = AppLocalizations.of(context)!.statusDownloadingEngine;
    });

    try {
      await _ytDlp.ensureBinaries((name, p) {
        setState(() {
          _progress = p;
          _status = 'Downloading $name: ${(p * 100).toStringAsFixed(1)}%';
        });
      });
      if (!mounted) return;
      setState(() {
        _isSettingUp = false;
        _progress = 0.0;
        _status = AppLocalizations.of(context)!.statusSetupComplete;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSettingUp = false;
        _status = 'Setup failed: $e';
      });
      _showError('Engine setup failed. Check logs.');
    }
  }

  Future<void> _convertVideo() async {
    if (!_ytDlp.isReady) {
      await _setupEngine();
      if (!_ytDlp.isReady) return;
    }

    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a YouTube URL');
      return;
    }

    if (_downloadDirectory.isEmpty) {
      _showError('Please wait for directory initialization or select one');
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _status = AppLocalizations.of(context)!.statusStartingDownload;
    });

    _ytDlp.clearLogs();

    try {
      final dir = Directory(_downloadDirectory);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      final outputPath = p.join(_downloadDirectory, '%(title)s.%(ext)s');

      await _ytDlp.downloadMp3(
        url, 
        outputPath, 
        (status) => setState(() => _status = status), 
        (progress) => setState(() => _progress = progress),
        bitrate: _selectedBitrate,
        embedLyrics: _embedLyrics,
      );

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
        _status = AppLocalizations.of(context)!.statusDownloadComplete;
        _progress = 1.0;
      });

      _showSuccess(AppLocalizations.of(context)!.statusSaved);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _status = 'Error occurred. See logs.';
      });
      _showError('Failed: $e\nCheck the log for details.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.engineLogs),
        content: SizedBox(
          width: 600,
          height: 400,
          child: ListView.builder(
            itemCount: _ytDlp.logs.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                _ytDlp.logs[index],
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canInteract = !_isDownloading && !_isSettingUp;

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                labelType: NavigationRailLabelType.all,
                backgroundColor: const Color(0xFF161616),
                indicatorColor: const Color(0xFFFF0000).withValues(alpha: 0.2),
                selectedIconTheme: const IconThemeData(color: Color(0xFFFF0000)),
                unselectedIconTheme: const IconThemeData(color: Colors.grey),
                selectedLabelTextStyle: const TextStyle(color: Color(0xFFFF0000), fontSize: 12),
                unselectedLabelTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.explore_outlined),
                    selectedIcon: const Icon(Icons.explore),
                    label: Text(AppLocalizations.of(context)!.navExplore),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.link_outlined),
                    selectedIcon: const Icon(Icons.link),
                    label: Text(AppLocalizations.of(context)!.navDirect),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    label: Text(AppLocalizations.of(context)!.navSettings),
                  ),
                ],
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Icon(Icons.music_video_rounded, size: 32, color: Color(0xFFFF0000)),
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
                    ),
                  ),
                  child: _buildPageContent(canInteract),
                ),
              ),
            ],
          ),
          if (_isDownloading || _isSettingUp)
            Positioned(
              left: 80,
              right: 16,
              bottom: 16,
              child: _buildProgressFloatingCard(),
            ),
        ],
      ),
    );
  }



  Widget _buildPageContent(bool canInteract) {
    switch (_selectedIndex) {
      case 0:
        return _buildExplorePage(canInteract);
      case 1:
        return _buildDirectLinkPage(canInteract);
      case 2:
        return _buildSettingsPage(canInteract);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInputUrl(bool canInteract) {
    return TextField(
      controller: _urlController,
      enabled: canInteract,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.urlHint,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        prefixIcon: const Icon(Icons.link),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEmbedLyrics(bool canInteract) {
    return Row(
      children: [
        Switch(
          value: _embedLyrics,
          onChanged: canInteract ? (val) => setState(() => _embedLyrics = val) : null,
          activeThumbColor: const Color(0xFFFF0000),
        ),
        Text(AppLocalizations.of(context)!.embedLyrics, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: _progress > 0 ? _progress : null,
        minHeight: 8,
        backgroundColor: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildStatus() {
    return Text(
      _status,
      style: const TextStyle(color: Colors.grey),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildButton(bool canInteract) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canInteract ? _convertVideo : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF0000),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isDownloading || _isSettingUp
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(!_ytDlp.isReady 
                ? AppLocalizations.of(context)!.initEngineButton 
                : AppLocalizations.of(context)!.downloadButton),
      ),
    );
  }

  Widget _buildLogsButton() {
    return TextButton.icon(
      onPressed: _showLogsDialog,
      icon: const Icon(Icons.list_alt, color: Colors.grey),
      label: Text(AppLocalizations.of(context)!.viewLogs, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildSearchBar(bool canInteract) {
    return TextField(
      controller: _searchController,
      enabled: canInteract,
      onSubmitted: (_) => _performSearch(),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.searchHint,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: canInteract ? _performSearch : null,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSearchResults(bool canInteract) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white.withValues(alpha: 0.03),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['thumbnail']!,
                width: 80,
                height: 45,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(width: 80, height: 45, color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            title: Text(item['title']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
            subtitle: Text(item['duration']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.download_rounded, color: Color(0xFFFF0000)),
              onPressed: canInteract ? () => _onResultSelected(item) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildExplorePage(bool canInteract) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.exploreTitle, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Text(AppLocalizations.of(context)!.exploreSubtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          _buildSearchBar(canInteract),
          const SizedBox(height: 32),
          if (_isSearching)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(color: Color(0xFFFF0000)),
              ),
            )
          else if (_searchResults.isNotEmpty)
            _buildSearchResults(canInteract)
          else
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.search_rounded, size: 80, color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.searchPrompt, style: const TextStyle(color: Colors.white24)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDirectLinkPage(bool canInteract) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link_rounded, size: 64, color: Color(0xFFFF0000)),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.directTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.directSubtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _buildInputUrl(canInteract),
            const SizedBox(height: 24),
            _buildButton(canInteract),
            if (_ytDlp.logs.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildLogsButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPage(bool canInteract) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.settingsTitle, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Text(AppLocalizations.of(context)!.settingsSubtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 48),
          
          Text(AppLocalizations.of(context)!.audioQuality, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            width: 300,
            child: DropdownButtonFormField<String>(
              initialValue: _selectedBitrate,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: _bitrates.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: canInteract ? (val) {
                if (val != null) setState(() => _selectedBitrate = val);
              } : null,
            ),
          ),
          
          const SizedBox(height: 32),
          Text(AppLocalizations.of(context)!.saveLocation, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          InkWell(
            onTap: canInteract ? _pickDirectory : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_open, color: Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(_downloadDirectory.isEmpty ? AppLocalizations.of(context)!.loading : _downloadDirectory),
                  ),
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          Text(AppLocalizations.of(context)!.metadata, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildEmbedLyrics(canInteract),

          const SizedBox(height: 32),
          Text(AppLocalizations.of(context)!.languageSettings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            width: 300,
            child: DropdownButtonFormField<String>(
              initialValue: appLocale.value.languageCode,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.currentLanguage,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: [
                DropdownMenuItem(value: 'ko', child: Text(AppLocalizations.of(context)!.korean)),
                DropdownMenuItem(value: 'en', child: Text(AppLocalizations.of(context)!.english)),
              ],
              onChanged: canInteract ? (val) {
                if (val != null) {
                  appLocale.value = Locale(val);
                }
              } : null,
            ),
          ),
          
          const SizedBox(height: 48),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          const Text('MP3Box v1.0.0', style: TextStyle(color: Colors.white24, fontSize: 12)),
          const Text('@Daddyhouse, Powered by yt-dlp & FFmpeg', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProgressFloatingCard() {
    return Card(
      elevation: 8,
      color: const Color(0xFF252525),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF0000)),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildStatus()),
                const SizedBox(width: 16),
                Text('${(_progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
