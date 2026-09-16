검은 기록 v0.4.1 — 한상철 야간 추적 퀘스트 패치

의미 있는 변경:
- NIGHT_WATCH가 21:39 이후 자동으로 FOLLOW_MAYOR로 전환
- 한상철과 105~235px 적정 미행 거리 시스템
- 82px 이내 2.6초 유지 시 발각 처리 및 안전 체크포인트 복귀
- 330px 이상 4.5초 유지 시 추적 실패 처리 및 체크포인트 복귀
- 미행 거리 HUD/위험도 게이지 추가
- 북쪽 숲 도착 성공 시 FOREST_ENTRY 전환
- night_follow_complete / north_forest_unlocked 플래그 저장
- 기존 main.gd, npc.gd, game_state.gd를 직접 덮어쓰지 않아 이전 플레이 흐름 보존

적용:
1. scripts/follow_quest_controller.gd를 프로젝트 scripts 폴더에 복사
2. project.godot에 이미 [autoload]가 없으면 아래 2줄 추가:
   [autoload]
   NightPursuit="*res://scripts/follow_quest_controller.gd"
3. 이미 [autoload]가 있으면 해당 섹션 아래 NightPursuit 한 줄만 추가
4. F5 실행

주의: 현재 GitHub 연결은 쓰기 권한이 거부되어 저장소에 직접 커밋하지 못했고, 로컬 적용 패치로 제작했습니다.
