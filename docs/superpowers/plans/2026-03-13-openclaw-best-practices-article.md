# OpenClaw Workspace Best Practices Article Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `04. SOUL.md와 MEMORY.md 베스트 프랙티스 3가지` 글을 작성한다.

**Architecture:** 공식 문서로 파일 역할 경계를 고정하고, GitHub star가 높은 OpenClaw community 자료에서 실제 운영 패턴 3개를 뽑아 사례형 글로 정리한다. 각 사례는 바로 복붙 가능한 SOUL/MEMORY 예시까지 포함한다.

**Tech Stack:** Quartz Markdown, frontmatter, Mermaid, local attachfiles image

---

## Chunk 1: Research

**Files:**
- Create: `docs/superpowers/specs/2026-03-13-openclaw-best-practices-design.md`
- Create: `docs/superpowers/plans/2026-03-13-openclaw-best-practices-article.md`
- Create: `content/#05 AI/#01 Open-Claw/04-SOUL.md와 MEMORY.md 베스트 프랙티스 3가지 - 개발, 리서치, 개인 비서형.md`

- [ ] Review official docs for SOUL/MEMORY/AGENTS boundaries
- [ ] Review starred GitHub sources and extract 3 use-case patterns
- [ ] Choose copy-paste examples for each use case

## Chunk 2: Write

**Files:**
- Create: `content/#05 AI/#01 Open-Claw/04-SOUL.md와 MEMORY.md 베스트 프랙티스 3가지 - 개발, 리서치, 개인 비서형.md`

- [ ] Write intro and why starred GitHub patterns are useful
- [ ] Explain common boundaries first
- [ ] Write 3 use-case sections with examples
- [ ] Add “bad example” guidance per section
- [ ] End with practical rollout order

## Chunk 3: Verify

**Files:**
- Modify: `content/#05 AI/#01 Open-Claw/04-SOUL.md와 MEMORY.md 베스트 프랙티스 3가지 - 개발, 리서치, 개인 비서형.md`

- [ ] Confirm all references are valid Markdown links
- [ ] Run Quartz build
- [ ] Confirm no rendering errors
