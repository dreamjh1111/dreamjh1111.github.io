# Repeatable Read Article Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 홈서버 활용기 카테고리에 `Repeatable Read` 입문 글을 새로 추가한다.

**Architecture:** 기존 DB 글과 동일한 Markdown frontmatter와 설명형 구조를 사용한다. 본문은 쉬운 예제, 머메이드 도식, InnoDB 기준 설명, 실무 문제 섹션, 참고 자료 섹션으로 구성한다.

**Tech Stack:** Quartz Markdown, Mermaid, MySQL 공식 문서 링크

---

## Chunk 1: Research And Structure

### Task 1: Gather source links and lock the outline

**Files:**
- Create: `content/#02 홈서버/#02 홈서버 활용기/Repeatable Read란 무엇인가 - MySQL에서 같은 SELECT가 같은 결과를 보는 이유.md`
- Create: `docs/superpowers/specs/2026-03-10-repeatable-read-article-design.md`
- Create: `docs/superpowers/plans/2026-03-10-repeatable-read-article.md`

- [x] **Step 1: Confirm the topic and article structure**

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
- `https://dev.mysql.com/doc/refman/8.4/en/innodb-transaction-isolation-levels.html`
- `https://dev.mysql.com/doc/refman/8.4/en/innodb-consistent-read.html`
- `https://dev.mysql.com/doc/refman/8.4/en/innodb-next-key-locking.html`

Expected: article claims are grounded in primary documentation.

## Chunk 2: Write The Article

### Task 2: Draft the new Markdown post

**Files:**
- Create: `content/#02 홈서버/#02 홈서버 활용기/Repeatable Read란 무엇인가 - MySQL에서 같은 SELECT가 같은 결과를 보는 이유.md`

- [x] **Step 1: Add frontmatter and introduction**

Include title, description, date, tags, and an intro that connects isolation levels to practical confusion.

- [x] **Step 2: Add the easy example and first diagram**

Use a small order or inventory example to explain snapshot reads.

- [x] **Step 3: Add InnoDB explanation and the confusing point**

Explain that plain `SELECT` behaves differently from locking reads like `SELECT ... FOR UPDATE`.

- [x] **Step 4: Add the real-world section**

Cover stale reads, mixing reads and writes in one transaction, and when developers misjudge current state.

- [x] **Step 5: Add mitigation points and references**

Close with practical guidance and official links.

## Chunk 3: Verify Rendering

### Task 3: Build Quartz output

**Files:**
- Modify: `content/#02 홈서버/#02 홈서버 활용기/Repeatable Read란 무엇인가 - MySQL에서 같은 SELECT가 같은 결과를 보는 이유.md`

- [x] **Step 1: Run site build**

Run: `node ./quartz/bootstrap-cli.mjs build`
Expected: build completes successfully without markdown or mermaid parsing errors.
