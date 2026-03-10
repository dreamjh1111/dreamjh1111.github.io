# Next-Key Lock Article Design

## Goal

`Next-Key Lock`을 입문자도 이해할 수 있게 설명하고, MySQL `InnoDB`가 왜 행 하나만이 아니라 범위까지 함께 잠그는지, 실무에서는 어떤 대기와 혼란으로 이어지는지 한 편의 글로 정리한다.

## Audience

- `Repeatable Read`를 읽었고 다음 심화 개념으로 넘어가려는 사람
- `SELECT ... FOR UPDATE`를 썼는데 왜 예상보다 넓게 막히는지 궁금한 사람
- 범위 조회 후 수정 시 동시성 문제가 헷갈리는 백엔드 개발자

## Structure

1. 도입: 왜 `Next-Key Lock`을 알아야 하는가
2. 쉬운 예제: 범위 조회 중 새 데이터가 끼어드는 상황
3. 머메이드 도식: 레코드 락과 갭이 함께 잠기는 흐름
4. 핵심 설명: record lock, gap lock, next-key lock의 관계
5. `Repeatable Read`와의 연결: 팬텀 방지 관점
6. 실무에서 문제 되는 경우: 범위 조건 조회, `FOR UPDATE`, 대기 증가
7. 대응 포인트: 인덱스, 조건 범위, 트랜잭션 길이
8. 참고 자료: MySQL 공식 문서 중심

## Content Notes

- 기존 1, 2편과 동일한 문체와 난이도를 유지한다.
- `Gap Lock` 글과 완전히 중복되지 않도록, 이번 편은 "왜 범위까지 잠그는가"에 초점을 둔다.
- 공식 문서 링크는 본문 중간과 참고 자료에 배치한다.
- 그림보다 머메이드 도식이 설명 효율이 더 높으므로 도식 중심으로 간다.
