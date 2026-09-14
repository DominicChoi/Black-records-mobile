# Android APK 자동 빌드

이 프로젝트는 GitHub Actions에서 설치 가능한 Android Debug APK를 자동 생성합니다.

## 최초 1회
1. GitHub에서 새 저장소를 하나 만듭니다. 권장 이름: `black-records-mobile`.
2. 이 프로젝트의 **내용물 전체**를 저장소 루트에 업로드합니다. `project.godot`가 저장소 최상단에 있어야 합니다.
3. 저장소의 **Actions** 탭에서 `Build Android APK`를 엽니다.
4. `Run workflow`를 누릅니다.

`main` 브랜치에 게임 파일을 수정해서 올려도 자동으로 새 APK가 빌드됩니다.

## 휴대폰에서 설치
1. GitHub 저장소 → **Actions** → 가장 최근 성공한 `Build Android APK` 실행을 엽니다.
2. 아래 **Artifacts**에서 `BlackRecords-Android-v0.2.0`을 다운로드합니다.
3. ZIP을 휴대폰에서 압축 해제합니다.
4. `BlackRecords-v0.2.0-debug.apk`를 탭해 설치합니다.
5. Android가 요청하면 해당 브라우저/파일 앱의 **알 수 없는 앱 설치 허용**을 1회 켭니다.

## 참고
- 이 APK는 개발/테스트용 Debug 서명입니다. 본인 휴대폰 직접 설치에는 사용할 수 있습니다.
- Play Store 배포 단계에서는 별도의 Release keystore와 AAB 빌드로 전환해야 합니다.
- keystore는 Git에 저장하지 않습니다. CI 실행 중 임시로 만들어지고 실행 종료 후 사라집니다.
