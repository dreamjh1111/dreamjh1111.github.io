# Repeatable Read Article Design

## Goal

`Repeatable Read`를 입문자도 이해할 수 있게 설명하고, MySQL `InnoDB` 기준으로 왜 같은 트랜잭션 안에서 같은 `SELECT`가 같은 결과처럼 보이는지, 실무에서는 어떤 오해와 문제가 생기는지를 한 편의 글로 정리한다.

## Audience

- DB를 막 공부하기 시작한 백엔드 개발자
- MySQL `InnoDB`를 쓰지만 격리 수준이 헷갈리는 사람
- "조회는 분명 이렇게 봤는데 왜 수정 결과는 다르지?" 같은 경험이 있는 사람

## Structure

1. 도입: 왜 `Repeatable Read`를 알아야 하는가
2. 쉬운 예제: 같은 트랜잭션 안에서 두 번 조회하는 상황
3. 머메이드 도식: 스냅샷 읽기 흐름
4. 핵심 설명: `Repeatable Read`, `consistent read`, 첫 읽기 시점의 스냅샷
5. 주의점: 일반 `SELECT`와 `SELECT ... FOR UPDATE` 차이
6. 실무에서 문제 되는 경우: stale read, 조회 후 수정, 혼합 사용
7. 대응 포인트: 짧은 트랜잭션, locking read, 격리 수준 선택
8. 참고 자료: MySQL 공식 문서 중심

## Content Notes

- 문체와 난이도는 기존 DB 입문 글과 동일하게 유지한다.
- 개념만 설명하지 않고, 실무에서 헷갈리는 지점을 별도 섹션으로 둔다.
- 공식 문서 링크를 본문 중간과 참고 자료에 모두 배치한다.
- 이미지는 무리하게 추가하지 않고, 설명 가치가 있는 경우에만 사용한다.
