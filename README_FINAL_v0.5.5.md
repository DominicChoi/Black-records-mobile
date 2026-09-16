# 검은 기록 Prototype FINAL v0.5.5 — PC 정리본

기준 원본: 사용자가 제공한 `Black-records-mobile.zip` (v0.5.0 계열 전체 프로젝트)
누적 반영: v0.5.2 → v0.5.3 → v0.5.4 → v0.5.5

## 누적 반영 내용
- v0.5.2: 플레이어/NPC 이동 애니메이션, 가감속, 보행 bob/sway, 접지 그림자, 조사 포즈
- v0.5.3: 경찰지소/마을회관/여관 실내 배경, 미니맵/모바일 UI 개선
- v0.5.4: 실내 실제 입장/퇴장, NPC 시간대별 대화/생활감 강화
- v0.5.5: 밤/안개/이슬비/노면 반사, FOLLOW_MAYOR 추적 시야 효과

## 병합 시 안전 유지
- 원본 main.gd / mobile_joystick.gd 포함
- 기존 follow_quest_controller.gd 유지
- 기존 월드/퀘스트 좌표 유지
- v0.5.5 WeatherFX는 main.gd에서 quest 상태까지 전달하도록 호출부를 병합

## PC에서 열기
Godot 4.x에서 이 폴더의 `project.godot`을 Import/Open 후 F6가 아닌 F5로 프로젝트 실행.
Android 빌드 관련 기존 BAT/PS1/문서도 원본 그대로 포함되어 있습니다.

## 다음 개발 우선순위
1. 한상철 추적: 거리 유지/발각/놓침/회복/숲 도달 규칙
2. 북쪽 숲 독립 탐험 구역 확장
3. 폐광 입구 독립 탐험 구역 확장
