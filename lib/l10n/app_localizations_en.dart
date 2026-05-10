// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MP3Box';

  @override
  String get appSubtitle => 'YouTube to MP3';

  @override
  String get navExplore => 'Explore';

  @override
  String get navDirect => 'Direct';

  @override
  String get navSettings => 'Settings';

  @override
  String get exploreTitle => 'Search & Explore';

  @override
  String get exploreSubtitle => 'Find your favorite music on YouTube';

  @override
  String get searchHint => 'Search YouTube videos...';

  @override
  String get searchPrompt => 'Enter a keyword to start';

  @override
  String get directTitle => 'Download from URL';

  @override
  String get directSubtitle => 'Paste a YouTube link below to convert';

  @override
  String get urlHint => 'https://www.youtube.com/watch?v=...';

  @override
  String get downloadButton => 'Download MP3';

  @override
  String get initEngineButton => 'Initialize Engine';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Configure your download preferences';

  @override
  String get audioQuality => 'Audio Quality';

  @override
  String get saveLocation => 'Save Location';

  @override
  String get metadata => 'Metadata';

  @override
  String get embedLyrics => 'Embed Lyrics (from description/subs)';

  @override
  String get loading => 'Loading...';

  @override
  String get engineLogs => 'Engine Logs';

  @override
  String get close => 'Close';

  @override
  String get viewLogs => 'View Detailed Logs';

  @override
  String get statusPasteUrl => 'Paste a YouTube URL to start';

  @override
  String get statusSetupRequired => 'Initial setup required (one-time)';

  @override
  String get statusDownloadingEngine => 'Downloading engine components...';

  @override
  String get statusSetupComplete => 'Setup complete! Ready to convert.';

  @override
  String get statusStartingDownload => 'Starting download...';

  @override
  String get statusDownloadComplete => 'Download complete!';

  @override
  String get statusSaved => 'Successfully saved!';

  @override
  String get errorPleaseEnterUrl => 'Please enter a YouTube URL';

  @override
  String get errorWaitInit =>
      'Please wait for directory initialization or select one';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get currentLanguage => 'Current Language';

  @override
  String get korean => 'Korean';

  @override
  String get english => 'English';
}
