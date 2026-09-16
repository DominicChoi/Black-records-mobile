# Android APK 로컬 빌드 가이드 (v0.5.0 기준)

현재 패치는 **세계 확장/그래픽 업그레이드**까지 완료한 상태입니다.
다만 이 작업 환경에는 Godot Android export toolchain 이 없어 **APK 자체를 여기서 직접 산출할 수는 없었습니다.**

## 로컬에서 APK 만드는 방법
1. Godot 4.3 stable 실행
2. 프로젝트 열기
3. `project.godot`에 autoload가 없다면 아래 추가

```ini
[autoload]
NightPursuit="*res://scripts/follow_quest_controller.gd"
```

4. `Project > Export...`
5. Android preset이 없으면 추가
6. Android export template / SDK / keystore 준비
7. Export Project → `black_records_v0_5_0_test.apk`

## 테스트 포인트
- 시작 지점이 중앙 광장으로 바뀌는지
- 카메라가 넓은 월드를 따라다니는지
- 미니맵에 OVERWORLD / 랜드마크 / 현재 시야 박스가 보이는지
- 북쪽 숲 / 폐광 입구 / 남쪽 호수까지 이동했을 때 맵이 좁지 않게 느껴지는지
- 밤 21:39 이후 야간 추적 퀘스트가 숲 입구까지 정상 동작하는지
