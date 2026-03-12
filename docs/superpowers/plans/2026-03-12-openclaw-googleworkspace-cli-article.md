# OpenClaw Google Workspace CLI Article Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** OpenClaw에 `googleworkspace/cli`를 연결하는 방법과 Gmail, Calendar, Drive 활용 사례를 한 글로 정리한 시리즈 05번 글을 추가한다.

**Architecture:** 공식 저장소 README와 스킬 문서를 기준으로 설치, 인증, OpenClaw 연동 순서를 고정한다. 본문은 짧은 튜토리얼 뒤에 활용 시나리오와 업무 자동화 예시를 길게 배치하고, 로컬 이미지와 Mermaid로 흐름을 보강한다.

**Tech Stack:** Quartz Markdown, frontmatter, Mermaid, local attachfiles image/gif

---

## Chunk 1: Research

**Files:**
- Create: `docs/superpowers/specs/2026-03-12-openclaw-googleworkspace-cli-design.md`
- Create: `docs/superpowers/plans/2026-03-12-openclaw-googleworkspace-cli-article.md`
- Create: `content/#05 AI/#01 Open-Claw/05-OpenClaw에 googleworkspace-cli 붙이기 - 설치, 인증, 활용까지 한 번에 정리하기.md`

- [ ] Review official `googleworkspace/cli` README for install, auth, and OpenClaw setup
- [ ] Review `docs/skills.md` and selected skill files for concrete Gmail, Calendar, Drive examples
- [ ] Review external tutorials and discussion posts for real-world usage framing

## Chunk 2: Write

**Files:**
- Create: `content/#05 AI/#01 Open-Claw/05-OpenClaw에 googleworkspace-cli 붙이기 - 설치, 인증, 활용까지 한 번에 정리하기.md`

- [ ] Write intro and why `gws` is useful inside OpenClaw
- [ ] Write short install/auth section with scope and testing-mode caveats
- [ ] Write OpenClaw skill install section with recommended minimal skill set
- [ ] Write Gmail, Calendar, Drive, and automation scenario sections with prompt examples
- [ ] Add Mermaid flow and local visual assets

## Chunk 3: Verify

**Files:**
- Modify: `content/#05 AI/#01 Open-Claw/05-OpenClaw에 googleworkspace-cli 붙이기 - 설치, 인증, 활용까지 한 번에 정리하기.md`

- [ ] Confirm image references point to local `content/attachfiles/`
- [ ] Confirm command examples match the official repository
- [ ] Run Quartz build
- [ ] Confirm no rendering errors
