검은 기록 v0.5.1 — APK Test Pack

현재 v0.5.0 월드 확장 패치를 적용한 PC 프로젝트에서
Galaxy 설치용 Debug APK를 빠르게 만들기 위한 패키지입니다.

적용:
1. 이 ZIP의 export_presets.cfg를 현재 검은 기록 프로젝트 루트에 덮어씁니다.
2. 나머지 01/02/03 파일들도 프로젝트 루트에 복사합니다.
3. 01_CHECK_ANDROID.bat 실행
4. 큰 항목이 모두 OK면 02_BUILD_APK.bat 실행
5. 성공 시 build/BlackRecords-v0.5.0-debug.apk 생성
6. Fold 7 USB 디버깅 연결 후 03_INSTALL_TO_PHONE.bat 실행

중요:
- project.godot에 0.4.1에서 등록한 NightPursuit autoload는 그대로 유지하십시오.
- 이 패키지는 게임 내용/맵/퀘스트를 변경하지 않고 Android export 설정과 로컬 빌드 자동화만 추가합니다.
- APK 생성에 실패하면 CMD/PowerShell의 마지막 오류 화면을 그대로 캡처해서 보내주시면 됩니다.
