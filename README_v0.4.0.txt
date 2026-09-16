검은 기록 v0.4.0 — JRPG Visual Overhaul

이번 패스는 PC에서 정상 실행된 v0.2.x 기준 구조를 깨지 않으면서 실제 플레이 화면을 크게 바꾸는 교체 패치입니다.

완료
- 주인공 4방향 × 4프레임 실제 PNG 스프라이트 애니메이션
- 한상철 / 정우진 / 장도식 개별 PNG 스프라이트
- 은령마을 1280×720 신규 일러스트형 필드 배경
- 전경 Occlusion 레이어 추가(하단 수풀/교량 난간/수목 캐노피)
- 기존 시간대에 따라 청색/황혼 Tint 변화 유지
- 가로등 glow / 하천 shimmer 유지
- minimap.gd player null 런타임 오류 수정
- 미니맵 가독성 개선
- 기존 CharacterBody2D, set_mobile_input(), NPC get_dialogue(), get_schedule_label(), quest/save 흐름 유지
- 버전 표시 v0.4.0 갱신

적용 방법
1) 현재 정상 실행되는 Black-records-mobile 폴더를 백업합니다.
2) 이 ZIP의 내용을 프로젝트 루트에 그대로 덮어씁니다.
3) Godot으로 돌아가면 리소스 Import가 끝날 때까지 잠시 기다립니다.
4) F5를 누릅니다.
5) 오류가 뜨면 수정하지 말고 화면 캡처를 보내주세요.

주의
- Android export preset은 이번 ZIP에서 변경하지 않았습니다. 로컬 F5 플레이 안정성을 우선했습니다.
- 기존 게임 상태/퀘스트/저장 구조는 변경하지 않았습니다.
