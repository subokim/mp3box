import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MP3Box'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'YouTube to MP3'**
  String get appSubtitle;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get navDirect;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Search & Explore'**
  String get exploreTitle;

  /// No description provided for @exploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your favorite music on YouTube'**
  String get exploreSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search YouTube videos...'**
  String get searchHint;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter a keyword to start'**
  String get searchPrompt;

  /// No description provided for @directTitle.
  ///
  /// In en, this message translates to:
  /// **'Download from URL'**
  String get directTitle;

  /// No description provided for @directSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste a YouTube link below to convert'**
  String get directSubtitle;

  /// No description provided for @urlHint.
  ///
  /// In en, this message translates to:
  /// **'https://www.youtube.com/watch?v=...'**
  String get urlHint;

  /// No description provided for @downloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download MP3'**
  String get downloadButton;

  /// No description provided for @initEngineButton.
  ///
  /// In en, this message translates to:
  /// **'Initialize Engine'**
  String get initEngineButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure your download preferences'**
  String get settingsSubtitle;

  /// No description provided for @audioQuality.
  ///
  /// In en, this message translates to:
  /// **'Audio Quality'**
  String get audioQuality;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get saveLocation;

  /// No description provided for @metadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get metadata;

  /// No description provided for @embedLyrics.
  ///
  /// In en, this message translates to:
  /// **'Embed Lyrics (from description/subs)'**
  String get embedLyrics;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @engineLogs.
  ///
  /// In en, this message translates to:
  /// **'Engine Logs'**
  String get engineLogs;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @viewLogs.
  ///
  /// In en, this message translates to:
  /// **'View Detailed Logs'**
  String get viewLogs;

  /// No description provided for @statusPasteUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste a YouTube URL to start'**
  String get statusPasteUrl;

  /// No description provided for @statusSetupRequired.
  ///
  /// In en, this message translates to:
  /// **'Initial setup required (one-time)'**
  String get statusSetupRequired;

  /// No description provided for @statusDownloadingEngine.
  ///
  /// In en, this message translates to:
  /// **'Downloading engine components...'**
  String get statusDownloadingEngine;

  /// No description provided for @statusSetupComplete.
  ///
  /// In en, this message translates to:
  /// **'Setup complete! Ready to convert.'**
  String get statusSetupComplete;

  /// No description provided for @statusStartingDownload.
  ///
  /// In en, this message translates to:
  /// **'Starting download...'**
  String get statusStartingDownload;

  /// No description provided for @statusDownloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download complete!'**
  String get statusDownloadComplete;

  /// No description provided for @statusSaved.
  ///
  /// In en, this message translates to:
  /// **'Successfully saved!'**
  String get statusSaved;

  /// No description provided for @errorPleaseEnterUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a YouTube URL'**
  String get errorPleaseEnterUrl;

  /// No description provided for @errorWaitInit.
  ///
  /// In en, this message translates to:
  /// **'Please wait for directory initialization or select one'**
  String get errorWaitInit;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
