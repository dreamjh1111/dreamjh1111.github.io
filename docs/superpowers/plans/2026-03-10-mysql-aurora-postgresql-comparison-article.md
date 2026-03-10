# MySQL Aurora PostgreSQL Comparison Article Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 데이터베이스 카테고리에 `MySQL`, `Aurora MySQL-compatible`, `PostgreSQL` 비교 글을 추가한다.

**Architecture:** 기존 DB 시리즈와 동일한 Markdown frontmatter와 설명형 구조를 사용한다. 본문은 배경 스토리, 기술 축별 비교, 사용자 관점 선택 기준, 공식 문서 링크 섹션으로 구성한다.

**Tech Stack:** Quartz Markdown, Mermaid, 공식 MySQL/AWS/PostgreSQL 문서 링크

---

## Chunk 1: Research And Structure

### Task 1: Lock the comparison scope and source set

**Files:**
- Create: `content/#03 데이터베이스/05-MySQL, Aurora MySQL, PostgreSQL은 무엇이 다를까 - 탄생 배경부터 구조와 선택 기준까지.md`
- Create: `docs/superpowers/specs/2026-03-10-mysql-aurora-postgresql-comparison-design.md`
- Create: `docs/superpowers/plans/2026-03-10-mysql-aurora-postgresql-comparison-article.md`

- [x] **Step 1: Fix the comparison scope**

Use:
- MySQL with InnoDB
- Aurora MySQL-compatible
- PostgreSQL

- [x] **Step 2: Fix the source categories**

Use official sources for:
- history/background
- architecture/storage
- MVCC and locking
- isolation levels
- indexes
- replication/HA

Expected: article claims remain grounded in primary documentation.

## Chunk 2: Write The Article

### Task 2: Draft the new Markdown post

**Files:**
- Create: `content/#03 데이터베이스/05-MySQL, Aurora MySQL, PostgreSQL은 무엇이 다를까 - 탄생 배경부터 구조와 선택 기준까지.md`

- [x] **Step 1: Add frontmatter and introduction**

Include title, description, date, tags, and an intro that connects engine study to product comparison.

- [x] **Step 2: Add background story section**

Cover product origins, timeline context, and inferred design philosophy.

- [x] **Step 3: Add technical comparison sections**

Compare storage, MVCC, isolation, locking, indexing, replication, and operations.

- [x] **Step 4: Add user-facing takeaways**

At the end of each major part, explain what the difference feels like to the user or operator.

- [x] **Step 5: Add final selection guide and references**

Close with scenario-based recommendations and official links.

## Chunk 3: Verify Rendering

### Task 3: Build Quartz output

**Files:**
- Modify: `content/#03 데이터베이스/05-MySQL, Aurora MySQL, PostgreSQL은 무엇이 다를까 - 탄생 배경부터 구조와 선택 기준까지.md`

- [x] **Step 1: Run site build**

Run: `node ./quartz/bootstrap-cli.mjs build`
Expected: build completes successfully without markdown or mermaid parsing errors.
