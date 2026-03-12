# OpenClaw Introduction Article Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `00. OpenClaw란 무엇인가` 글을 작성해 설치 글 앞에 배치한다.

**Architecture:** 공식 사이트와 문서로 제품 설명을 잡고, 한국어 커뮤니티/Reddit 반응으로 입문자 관점과 주의점을 보강한다. 본문은 짧게 유지하고 구조 설명은 Mermaid로 압축한다.

**Tech Stack:** Quartz Markdown, frontmatter, Mermaid, local attachfiles image

---

## Chunk 1: Research And Outline

**Files:**
- Create: `docs/superpowers/specs/2026-03-12-openclaw-introduction-design.md`
- Create: `docs/superpowers/plans/2026-03-12-openclaw-introduction-article.md`
- Create: `content/#05 AI/#01 Open-Claw/00-OpenClaw란 무엇인가 - 왜 주목받고, 무엇이 다른가.md`

- [ ] Review official references and community references
- [ ] Fix the article angle: intro-first, structure-second, caution-third
- [ ] Keep the outline shorter than the installation article

## Chunk 2: Write Article

**Files:**
- Create: `content/#05 AI/#01 Open-Claw/00-OpenClaw란 무엇인가 - 왜 주목받고, 무엇이 다른가.md`

- [ ] Write frontmatter and intro
- [ ] Add one local image reference from `content/attachfiles/`
- [ ] Add one Mermaid diagram for high-level architecture
- [ ] Add a short comparison section against ordinary chatbots
- [ ] Add a short caution section on security/cost/operations
- [ ] End with a link-style transition to the Ubuntu install article

## Chunk 3: Verify

**Files:**
- Modify: `content/#05 AI/#01 Open-Claw/00-OpenClaw란 무엇인가 - 왜 주목받고, 무엇이 다른가.md`

- [ ] Confirm the article file exists in the Open-Claw folder
- [ ] Confirm all image references are local
- [ ] Run Quartz build and verify no rendering errors
