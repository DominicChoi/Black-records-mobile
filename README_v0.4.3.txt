검은 기록 v0.4.3 — Illustrated Field Pass

목적
- v0.4.2에서 월드는 넓어졌지만 건물/배경이 여전히 도형처럼 보이는 문제를 줄이는 빠른 그래픽 교체 패스입니다.

변경
- 은령마을 시작/중앙 구간을 일러스트 기반 배경으로 교체
- 기존 1920x900 확장 월드/Camera2D/NPC 동선/미행 퀘스트 좌표는 유지
- 동쪽 폐광 구역은 v0.4.2의 확장 지형을 유지하면서 숲 전환부를 추가
- 기존 foreground occlusion 유지
- 밤/안개/가로등 효과 유지

적용
1. 현재 v0.4.2 프로젝트를 백업
2. ZIP의 assets/backgrounds 와 scripts 폴더를 프로젝트 루트에 덮어쓰기
3. Godot Import가 끝난 뒤 F5 실행

이 패치는 main.tscn, npc.gd, minimap.gd, follow quest를 건드리지 않으므로 v0.4.2/0.4.1 기능을 최대한 보존합니다.
