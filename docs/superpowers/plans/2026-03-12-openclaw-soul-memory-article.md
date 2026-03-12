# OpenClaw SOUL And MEMORY Article Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `03. SOUL.md와 MEMORY.md로 OpenClaw 말투와 기억 다듬기` 글을 작성한다.

**Architecture:** 공식 문서에서 workspace, bootstrapping, memory 로딩 규칙을 가져오고, 커뮤니티에서 실제로 부딪히는 `경계 혼동`, `기억 안 남음`, `너무 큰 MEMORY.md` 문제를 보강한다. 글은 개념을 먼저 짚고 바로 실전 수정 예시로 이어간다.

**Tech Stack:** Quartz Markdown, frontmatter, Mermaid, local attachfiles image

---

## Chunk 1: Research

**Files:**
- Create: `docs/superpowers/specs/2026-03-12-openclaw-soul-memory-design.md`
- Create: `docs/superpowers/plans/2026-03-12-openclaw-soul-memory-article.md`
- Create: `content/#05 AI/#01 Open-Claw/03-SOUL.md와 MEMORY.md로 OpenClaw 말투와 기억 다듬기.md`

- [ ] Review official docs for workspace, bootstrapping, SOUL template, and memory behavior
- [ ] Review community discussions about SOUL/MEMORY separation and common pitfalls
- [ ] Reuse existing local images in `content/attachfiles/`

## Chunk 2: Write

**Files:**
- Create: `content/#05 AI/#01 Open-Claw/03-SOUL.md와 MEMORY.md로 OpenClaw 말투와 기억 다듬기.md`

- [ ] Write the intro and why this step matters after Telegram
- [ ] Explain file location and loading behavior
- [ ] Compare `SOUL.md`, `MEMORY.md`, and briefly `AGENTS.md`
- [ ] Add practical edit examples for both files
- [ ] Add common mistakes and guardrails

## Chunk 3: Verify

**Files:**
- Modify: `content/#05 AI/#01 Open-Claw/03-SOUL.md와 MEMORY.md로 OpenClaw 말투와 기억 다듬기.md`

- [ ] Confirm local image references
- [ ] Run Quartz build
- [ ] Confirm no Markdown rendering errors
