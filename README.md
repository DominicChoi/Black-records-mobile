# 검은 기록 Mobile Prototype v0.2.2

HTML v0.1.12의 스토리/퀘스트 구조를 유지하면서 Godot 4 기반 모바일 전용 프로젝트로 전환한 첫 버전입니다.

## 구현됨
- 은령마을 1개 실제 플레이 씬
- CharacterBody2D 기반 주인공 이동
- 보행/팔/다리/코트/방향 표현을 코드 드로잉으로 구현
- 모바일 가상 조이스틱 + 조사/대화 버튼
- 한상철 / 정우진 / 장도식 NPC 3명
- NPC 간단 생활 루틴 이동
- 시간대별 NPC 대화
- 미니맵 및 플레이어 위치 표시
- 시간 흐름 / 야간 오버레이 / 안개 상태
- user:// 저장 파일 기반 자동 세이브
- Android ARM64 export preset
- HTML의 FOLLOW_MAYOR, NIGHT_WATCH 개념을 Godot 상태 시스템에 반영

## 실행
Godot 4.3+에서 `project.godot`를 열고 F6/F5 실행.
Android는 Editor > Manage Export Templates 설치 후 Android preset으로 Export.

## 다음 구현 우선순위
1. 건물 출입/실내 씬(경찰지소, 마을회관, 여관)
2. 실제 스프라이트 시트 및 8방향 애니메이션
3. 한상철 야간 추적 전용 AI/시야/은폐
4. 북쪽 숲 씬과 폐광 입구 씬
5. 증거/조사/대화 선택 UI 이식

## 주의
이 제작 환경에는 Godot 실행 바이너리가 없어 엔진 런타임 테스트/APK 빌드는 수행하지 못했습니다. 프로젝트 경로와 스크립트 참조는 정적 검증했습니다.

### v0.2.0 추가 점검 반영
- NPC routine 거리 제한 버그 수정: 장거리 루틴 포인트도 정상 이동
- 경찰지소 입구 근접 상호작용 추가
- `police_station.tscn` 실내 플레이 씬 및 마을 복귀 구현


## v0.2.2 Character Visual Pass
- 주인공을 8방향 판정 기반 프로시저럴 JRPG 캐릭터로 재작성
- 전/후/좌/우 방향에 따라 얼굴·뒷머리·가방·몸통 방향이 다르게 보이도록 개선
- 걷기 시 다리 교차, 팔 스윙, 바운스, 그림자 변화 추가
- NPC도 이동 방향을 실제 루틴 진행 방향에 맞춰 표시하고 보행 애니메이션 적용
- 한상철/정우진/장도식 외형 포인트(배지·기자 가방·관리인 벨트/수염) 분리
- NPC 이름/역할 네임플레이트 추가
- 기존 저장/대화/미니맵/Android CI 구조 유지


## Android CI
`.github/workflows/android-apk.yml`을 통해 GitHub Actions에서 Android Debug APK를 자동 생성합니다.
