# Windows Terminal iTerm-Style Key Mapping Article Design

## Goal

Windows와 macOS를 함께 쓰는 개발자의 관점에서, 우열 비교가 아니라 "익숙한 작업 흐름 통일"이라는 문제를 중심에 두고 Windows Terminal 키 매핑 후기를 정리한다.

## Audience

- macOS와 Windows를 함께 사용하는 개발자
- `iTerm`에 익숙한 손의 기억을 Windows Terminal에도 옮기고 싶은 사용자
- `settings.json`을 직접 만지더라도 맥락과 이유를 함께 알고 싶은 독자

## Structure

1. 도입: Windows와 macOS를 함께 쓰며 느끼는 작업 흐름의 차이
2. 문제 정의: 비교보다 중요한 것은 익숙한 개발 습관의 유지
3. 구현 전 불편함: pane 분할, pane 이동, 검색, 복사/붙여넣기
4. 적용한 키 매핑 표: iTerm 스타일 감각을 Windows Terminal에 맞춘 선택
5. 실제 `settings.json` 코드 블럭
6. 머메이드 다이어그램: 키 입력에서 동작까지의 흐름
7. 적용 후 체감 변화와 남는 한계
8. 참고 자료: Microsoft 공식 문서, iTerm2 관련 링크

## Content Notes

- "mac이 더 좋다"는 방향으로 쓰지 않고, 개발자 친화적인 기본 설정과 익숙함의 차이를 실무 감각으로 설명한다.
- 실제 로컬 `settings.json`에 들어 있는 매핑을 기준으로 서술한다.
- 이미지 2~3개, 머메이드 1~2개, JSON 코드 블럭을 포함한다.
- `Ctrl+D`가 셸의 EOF와 충돌할 수 있는 트레이드오프는 후기 섹션에서 함께 다룬다.
