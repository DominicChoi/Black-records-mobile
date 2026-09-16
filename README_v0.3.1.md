# 검은 기록 v0.3.1 — JRPG Illustrated Village Pass

이번 패스는 컨셉 이미지만 만드는 것이 아니라 실제 Godot에서 불러올 수 있는 게임 리소스를 생성했습니다.

포함:
- `assets/backgrounds/eunryeong_village_night_jrpg.jpg` : 1920×1080 JRPG풍 은령마을 야간 배경
- `scripts/illustrated_world.gd` : 배경을 Godot Canvas에 표시하는 레이어
- `assets/backgrounds/illustrated_village_layer.tscn` : 즉시 인스턴스 가능한 배경 레이어
- `docs/v0.3.1_visual_reference.png` : 아트 방향 기준

적용:
1. 위 파일들을 프로젝트 동일 경로에 추가합니다.
2. `scenes/main.tscn`의 `World` 아래 또는 `World`보다 뒤에 `illustrated_village_layer.tscn`을 인스턴스합니다.
3. 기존 `World` procedural 배경은 충돌/게임플레이 기준으로 남기되 시각 요소는 점차 전경 레이어로 분리합니다.
4. 기존 WeatherFX/NightOverlay는 그대로 유지합니다.

호환성:
- 기존 player/NPC/quest/save API 변경 없음
- 1920×1080 기준
- 외부 네트워크 의존성 없음
- 기존 날씨/조명 시스템과 분리되어 있어 롤백 가능

주의:
현재 배경은 Visual Pass 1입니다. 다음 패스에서는 UI가 섞이지 않은 순수 필드 원화, foreground occlusion 레이어,
캐릭터/NPC sprite sheet를 추가하여 실제 이동 시 나무/다리/건물 앞뒤 관계까지 구현합니다.
