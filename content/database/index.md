---
title: "데이터베이스"
description: "트랜잭션, MVCC, 격리 수준, 락, 동시성 제어를 실무 관점에서 정리한 데이터베이스 시리즈"
socialDescription: "MySQL과 PostgreSQL을 중심으로 트랜잭션, MVCC, Isolation Level, Lock을 실무형 예시로 정리한 글 모음"
date: 2026-03-10T17:40:00+09:00
navOrder: 3
tags:
  - database
  - mysql
  - postgresql
  - transaction
  - ko-kr
---

트랜잭션과 동시성 제어를 **실무 감각으로 이해하는 데이터베이스 시리즈**입니다.  
MySQL InnoDB를 중심으로 시작하되, PostgreSQL과의 차이까지 같이 잡는 흐름으로 구성했습니다.

## 이 시리즈에서 얻는 것
- DB 동시성 이슈를 감각이 아니라 구조로 이해
- MVCC, Isolation Level, Lock의 연결 관계 정리
- Lost Update, Gap Lock, Next-Key Lock 같은 실무 키워드 이해
- MySQL / PostgreSQL 차이를 비교하는 기준 확보

## 추천 읽기 순서
1. [[왜 DB를 알아야 할까 - MySQL InnoDB, 트랜잭션, MVCC, Lock 쉽게 이해하기]]
2. [[MySQL, Aurora MySQL, PostgreSQL은 무엇이 다를까 - 탄생 배경부터 구조와 선택 기준까지]]
3. [[MVCC란 무엇인가 - 왜 락을 덜 걸어도 읽기가 되는가]]
4. [[Repeatable Read란 무엇인가 - MySQL에서 같은 SELECT가 같은 결과를 보는 이유]]
5. [[Dirty Read, Non-Repeatable Read, Phantom Read 차이 - 트랜잭션 격리 수준을 읽기 이상 현상으로 이해하기]]
6. [[Lost Update란 무엇인가 - 트랜잭션이 있어도 데이터가 덮어써지는 이유]]
7. [[Gap Lock이란 무엇인가 - MySQL이 아직 없는 값까지 잠그는 이유]]
8. [[Next-Key Lock이란 무엇인가 - MySQL이 행 하나가 아니라 범위까지 잠그는 이유]]
9. [[Isolation Level이란 무엇인가 - Read Uncommitted, Read Committed, Repeatable Read, Serializable 차이 한 번에 정리하기]]

## 입문 / 핵심 / 심화
### 입문
- [[왜 DB를 알아야 할까 - MySQL InnoDB, 트랜잭션, MVCC, Lock 쉽게 이해하기]]
- [[MySQL, Aurora MySQL, PostgreSQL은 무엇이 다를까 - 탄생 배경부터 구조와 선택 기준까지]]

### 핵심
- [[MVCC란 무엇인가 - 왜 락을 덜 걸어도 읽기가 되는가]]
- [[Repeatable Read란 무엇인가 - MySQL에서 같은 SELECT가 같은 결과를 보는 이유]]
- [[Isolation Level이란 무엇인가 - Read Uncommitted, Read Committed, Repeatable Read, Serializable 차이 한 번에 정리하기]]

### 심화
- [[Lost Update란 무엇인가 - 트랜잭션이 있어도 데이터가 덮어써지는 이유]]
- [[Gap Lock이란 무엇인가 - MySQL이 아직 없는 값까지 잠그는 이유]]
- [[Next-Key Lock이란 무엇인가 - MySQL이 행 하나가 아니라 범위까지 잠그는 이유]]

## 함께 보면 좋은 카테고리
- [[블로그 구축기]]: SEO와 구조화 데이터, 기술 블로그 운영 정리
- [[AI]]: OpenClaw와 자동화 실험 기록
