v0.5.2 APK Build Fix

왜 필요한가:
- 별도 진단 스크립트에서 Godot Parse/Import는 이미 PASS했습니다.
- 기존 02_BUILD_APK.ps1이 같은 Parse 체크에서 잘못 중단되고 있으므로,
  이 버전은 중복 Parse 체크를 제거하고 바로 Android Export를 실행합니다.
- 실패하면 Android SDK / JDK / Export Template / keystore 등 실제 APK 오류를 화면에 출력합니다.

사용:
1. BUILD_APK_FIXED.ps1 / BUILD_APK_FIXED.bat 를 project.godot이 있는 프로젝트 루트에 복사
2. BUILD_APK_FIXED.bat 더블클릭
3. 성공: build/BlackRecords-v0.5.0-debug.apk 생성
4. 실패: 화면의 Important export lines 캡처해서 보내기

기존 게임 파일은 변경하지 않습니다.
