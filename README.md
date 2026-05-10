# MP3Box

Flutter로 개발된 윈도우용 YouTube to MP3 변환기입니다.
Flutter로 New Project를 생성한 다음 lib 폴더를 덮어쓰세요.

## 주요 기능

- **YouTube 검색**: 앱 내에서 YouTube 동영상을 직접 검색하고 탐색
- **직접 URL 다운로드**: YouTube URL을 붙여넣어 MP3로 다운로드
- **음질 옵션**: 128K, 192K, 320K 비트레이트 선택 가능
- **가사 임베딩**: MP3 파일에 가사 포함 옵션
- **다운로드 위치 설정**: 다운로드 폴더 자유롭게 선택 (기본값: 음악/MP3Box)
- **다국어 지원**: 한국어 및 영어 인터페이스
- **모던 UI**: Material 3 디자인, 다크 테마, YouTube 스타일의 레드 액센트
- **진행률 추적**: 실시간 다운로드 및 변환 진행률 표시
- **자동 업데이트**: yt-dlp 업데이트 자동 확인
- **엔진 로그**: 문제 해결을 위한 상세 로그 확인

## 아키텍처
윈도우 전용 애플리케이션으로 Flutter로 개발되었습니다.
Visual Studio 2022를 사용하여 빌드합니다.

### 프로젝트 구조

```
lib/
├── main.dart              # 메인 애플리케이션 및 UI, 상태 관리
├── properties.dart        # 앱 설정 및 상수
├── services/
│   └── yt_dlp_service.dart # YouTube 다운로드 및 변환 서비스
└── l10n/                  # 다국어 파일(영어, 한글)
    ├── app_en.arb
    ├── app_ko.arb
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    └── app_localizations_ko.dart
```

### 주요 컴포넌트

- **YtDlpService**: yt-dlp 및 FFmpeg 바이너리를 관리하고, 동영상 검색, 다운로드, 변환을 처리하는 싱글톤 서비스
- **ConversionPage**: 3개 탭(탐색, 직접 링크, 설정)을 갖는 메인 UI
- **Localization**: Flutter ARB 형식을 사용한 완전한 i18n 지원

### 기술 스택

- **프레임워크**: Flutter (Material 3)
- **언어**: Dart
- **다운로드 엔진**: yt-dlp
- **오디오 처리**: FFmpeg
- **현지화**: flutter_localizations
- **파일 처리**: file_picker, path_provider

## 빌드

```Powershell
# Windows 빌드
flutter build windows --debug
flutter build windows --release
```

## 첫 실행

첫 실행 시 MP3Box는 공식 GitHub 릴리스에서 필요한 바이너리(yt-dlp 및 FFmpeg)를 자동으로 다운로드하고 설정합니다.

## 앱 정보

- **버전**: 0.1.0
- **제작자**: Daddyhouse
- **웹사이트**: https://www.daddyhouse.net
- **플랫폼**: Windows 전용

## 기술 지원

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube 다운로더
- [FFmpeg](https://ffmpeg.org/) - 오디오 변환 및 처리