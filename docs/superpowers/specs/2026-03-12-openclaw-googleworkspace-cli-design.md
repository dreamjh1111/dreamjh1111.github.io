# OpenClaw Google Workspace CLI Article Design

## Goal

`#05 AI/#01 Open-Claw` 시리즈의 `05`번 글로, OpenClaw에 `googleworkspace/cli`를 붙이는 방법을 정리한다. 설치와 인증은 짧게 설명하되, 실제로 Gmail, Calendar, Drive를 어떤 흐름으로 써먹을 수 있는지 활용 시나리오와 업무 자동화 예시를 더 비중 있게 다룬다.

## Audience

- OpenClaw 설치와 Telegram 연결까지 마친 뒤 외부 업무 도구를 붙여 보고 싶은 독자
- Gmail, Calendar, Drive를 LLM에게 직접 만지게 하고 싶지만 OAuth와 스킬 구조가 헷갈리는 사용자
- API 문서보다 바로 따라 할 수 있는 실전형 예시를 원하는 독자

## Structure

1. 왜 `googleworkspace/cli`를 OpenClaw에 붙일 만한가
2. 설치와 인증의 최소 흐름
3. OpenClaw에서 어떤 스킬을 복사하거나 연결하면 되는가
4. 바로 써먹는 활용 시나리오
   - Gmail triage
   - Calendar meeting prep / freebusy
   - Drive 공유와 첨부파일 정리
5. 여러 기능을 묶는 업무 자동화 예시
6. 자주 막히는 지점과 운영 팁

## Constraints

- 공식 저장소 README와 스킬 문서를 우선 기준으로 쓴다
- OpenClaw 연결 방법은 저장소 README의 OpenClaw setup 섹션을 기준으로 쓴다
- 설치/인증 설명은 줄이되, `gcloud 필요 여부`, `manual OAuth`, `scope 제한`은 빠뜨리지 않는다
- 시각 자료는 외부 핫링크 없이 로컬 `attachfiles`만 사용한다
- 시리즈 톤을 유지하되 설명서처럼 건조하지 않게, "이걸 붙이면 무엇이 편해지는가"를 계속 중심에 둔다
