검은 기록 v0.4.2 — World Expansion & Visual Refresh

이번 패치에서 실제로 완료한 것
1) 은령마을 필드를 1280x720 한 화면 고정에서 벗어나 1920x900 확장 월드로 변경
2) Player 하위에 Camera2D 추가 → 이제 마을 전체를 이동하며 탐험 가능
3) 은령마을 그래픽 재구성: 서쪽 수호당, 중앙 광장, 북쪽 숲 샛길, 동쪽 폐광 관리소/폐광 입구 추가
4) 더 넓어진 미니맵으로 새 랜드마크(P/▲/M/S) 표시
5) NPC 동선 확대: 한상철/정우진/장도식이 넓어진 세계 좌표에서 움직임
6) v0.4.1 야간 추적 퀘스트 좌표를 확장 맵에 맞게 갱신
7) 기존 player.gd / main.gd / quest/save 흐름을 최대한 유지

적용 방법
- 기존 정상 실행 프로젝트를 백업
- 이 ZIP의 내용을 프로젝트 루트에 그대로 덮어쓰기
- 만약 0.4.1을 이미 적용했다면 scripts/follow_quest_controller.gd는 이 버전으로 자동 갱신됨
- Godot에서 리소스 Import 완료 후 F5 실행

주의
- project.godot의 [autoload] 섹션에 NightPursuit="*res://scripts/follow_quest_controller.gd" 가 이미 있다면 그대로 유지하면 됨
- [autoload]가 아직 없다면 0.4.1 README의 방식대로 추가 필요
- 이번 패치는 실내 배경까지는 아직 교체하지 않음. 다음 패스는 경찰지소 실내/북쪽 숲 별도 맵화 예정
