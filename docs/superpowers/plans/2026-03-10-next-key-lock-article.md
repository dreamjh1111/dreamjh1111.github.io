# Next-Key Lock Article Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 데이터베이스 카테고리에 `Next-Key Lock` 입문 글을 새로 추가한다.

**Architecture:** 기존 DB 글과 동일한 Markdown frontmatter와 설명형 구조를 사용한다. 본문은 쉬운 예제, 머메이드 도식, `InnoDB` 기준 설명, 실무 문제 섹션, 참고 자료 섹션으로 구성한다.

**Tech Stack:** Quartz Markdown, Mermaid, MySQL 공식 문서 링크

---

## Chunk 1: Research And Structure

### Task 1: Gather source links and fix the outline

**Files:**
- Create: `content/#03 데이터베이스/03-Next-Key Lock이란 무엇인가 - MySQL이 행 하나가 아니라 범위까지 잠그는 이유.md`
- Create: `docs/superpowers/specs/2026-03-10-next-key-lock-article-design.md`
- Create: `docs/superpowers/plans/2026-03-10-next-key-lock-article.md`

- [x] **Step 1: Confirm article scope**

Use the approved pattern:
- intro
- easy example
- mermaid diagrams
- InnoDB explanation
- real-world problems
- mitigation points
- sources

- [x] **Step 2: Verify official MySQL references**

Use:
- `https://dev.mysql.com/doc/refman/8.4/en/innodb-next-key-locking.html`
- `https://dev.mysql.com/doc/refman/8.4/en/innodb-locking.html`
- `https://dev.mysql.com/doc/refman/8.4/en/innodb-transaction-isolation-levels.html`

Expected: article claims are grounded in primary documentation.

## Chunk 2: Write The Article

### Task 2: Draft the new Markdown post

**Files:**
- Create: `content/#03 데이터베이스/03-Next-Key Lock이란 무엇인가 - MySQL이 행 하나가 아니라 범위까지 잠그는 이유.md`

- [x] **Step 1: Add frontmatter and introduction**

Include title, description, date, tags, and an intro that connects `Next-Key Lock` to practical confusion.

- [x] **Step 2: Add easy example and diagrams**

Use a reservation or coupon example to explain why range protection is needed.

- [x] **Step 3: Add InnoDB explanation**

Explain record lock, gap lock, and next-key lock without going too deep.

- [x] **Step 4: Add real-world problem section**

Cover range queries, `SELECT ... FOR UPDATE`, and wider-than-expected blocking.

- [x] **Step 5: Add mitigation points and references**

Close with practical guidance and official links.

## Chunk 3: Verify Rendering

### Task 3: Build Quartz output

**Files:**
- Modify: `content/#03 데이터베이스/03-Next-Key Lock이란 무엇인가 - MySQL이 행 하나가 아니라 범위까지 잠그는 이유.md`

- [x] **Step 1: Run site build**

Run: `node ./quartz/bootstrap-cli.mjs build`
Expected: build completes successfully without markdown or mermaid parsing errors.
