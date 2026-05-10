// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'MP3Box';

  @override
  String get appSubtitle => 'YouTube MP3 변환기';

  @override
  String get navExplore => '검색';

  @override
  String get navDirect => '직접 입력';

  @override
  String get navSettings => '설정';

  @override
  String get exploreTitle => '음악 검색';

  @override
  String get exploreSubtitle => 'YouTube에서 좋아하는 음악을 찾아보세요';

  @override
  String get searchHint => 'YouTube 비디오 검색...';

  @override
  String get searchPrompt => '음악 제목이나 아티스트를 검색하세요.';

  @override
  String get directTitle => 'URL 직접 입력';

  @override
  String get directSubtitle => 'YouTube 링크를 아래에 붙여 넣으세요';

  @override
  String get urlHint => 'https://www.youtube.com/watch?v=...';

  @override
  String get downloadButton => 'MP3 다운로드';

  @override
  String get initEngineButton => '엔진 초기화';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSubtitle => '다운로드 환경설정';

  @override
  String get audioQuality => '오디오 음질';

  @override
  String get saveLocation => '저장 위치';

  @override
  String get metadata => '메타데이터';

  @override
  String get embedLyrics => '가사 포함 (설명/자막에서 추출)';

  @override
  String get loading => '로딩 중...';

  @override
  String get engineLogs => '엔진 로그';

  @override
  String get close => '닫기';

  @override
  String get viewLogs => '상세 로그 보기';

  @override
  String get statusPasteUrl => 'YouTube URL을 붙여넣어 시작하세요';

  @override
  String get statusSetupRequired => '초기 설정이 필요합니다 (1회성)';

  @override
  String get statusDownloadingEngine => '엔진 구성 요소를 다운로드 중...';

  @override
  String get statusSetupComplete => '설정 완료! 변환 준비가 되었습니다.';

  @override
  String get statusStartingDownload => '다운로드 시작 중...';

  @override
  String get statusDownloadComplete => '다운로드 완료!';

  @override
  String get statusSaved => '성공적으로 저장되었습니다!';

  @override
  String get errorPleaseEnterUrl => 'YouTube URL을 입력해주세요';

  @override
  String get errorWaitInit => '디렉토리 초기화를 기다리거나 직접 선택해주세요';

  @override
  String get languageSettings => '언어 설정';

  @override
  String get currentLanguage => '현재 언어';

  @override
  String get korean => '한국어';

  @override
  String get english => '영어';
}
