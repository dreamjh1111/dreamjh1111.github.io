# Windows Terminal iTerm-Style Key Mapping Article Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `content/#04 OS/Windows` 아래에 Windows Terminal iTerm 스타일 키 매핑 후기를 새 Markdown 글로 추가하고 기존 `ee.txt`를 정리한다.

**Architecture:** 글은 후기 중심 도입부와 실전 설정 가이드를 결합한 하이브리드 구조로 작성한다. 실제 로컬 `settings.json` 매핑을 중심에 두고, Microsoft 공식 문서와 iTerm2 이미지 링크를 참고 자료 및 시각 자료로 사용한다.

**Tech Stack:** Quartz Markdown, Mermaid, Windows Terminal `settings.json`, Microsoft Learn, iTerm2 웹 자료

---

## Chunk 1: Source Confirmation And File Planning

### Task 1: Confirm the real key mapping and target files

**Files:**
- Create: `content/#04 OS/Windows/01-Windows Terminal을 iTerm처럼 쓰고 싶어서 - macOS 개발 습관을 Windows에 이식한 키 매핑 기록.md`
- Delete: `content/#04 OS/Windows/ee.txt`
- Create: `docs/superpowers/specs/2026-03-10-windows-terminal-iterm-keymapping-design.md`
- Create: `docs/superpowers/plans/2026-03-10-windows-terminal-iterm-keymapping-article.md`

- [x] **Step 1: Parse Windows Terminal settings**

Run: `Get-Content -Raw <settings-path> | ConvertFrom-Json`
Expected: JSON parses successfully.

- [x] **Step 2: Extract the applied keybindings**

Capture:
- `ctrl+d` -> right split
- `ctrl+shift+d` -> down split
- `ctrl+[` / `ctrl+]` -> focus movement
- `ctrl+shift+f` -> find
- `ctrl+c` / `ctrl+v` -> copy and paste
- `alt+shift+d` -> duplicate pane

## Chunk 2: Write The Post

### Task 2: Draft the Markdown article

**Files:**
- Create: `content/#04 OS/Windows/01-Windows Terminal을 iTerm처럼 쓰고 싶어서 - macOS 개발 습관을 Windows에 이식한 키 매핑 기록.md`

- [ ] **Step 1: Add frontmatter and intro**

Include title, description, socialDescription, date, draft, tags.

- [ ] **Step 2: Add reflective context**

Explain the mixed macOS/Windows workflow and why comparison is less useful than reducing context switching.

- [ ] **Step 3: Add key mapping table and JSON**

Document the actual keybindings from the local settings file.

- [ ] **Step 4: Add diagrams and images**

Use Mermaid to show the workflow and include remote images from Microsoft Learn and iTerm2.

- [ ] **Step 5: Add tradeoffs and references**

Document the `Ctrl+D` caveat and link to official references.

## Chunk 3: Verify Rendering

### Task 3: Build the site

**Files:**
- Modify: `content/#04 OS/Windows/01-Windows Terminal을 iTerm처럼 쓰고 싶어서 - macOS 개발 습관을 Windows에 이식한 키 매핑 기록.md`

- [ ] **Step 1: Run Quartz build**

Run: `node ./quartz/bootstrap-cli.mjs build`
Expected: build completes without Markdown, frontmatter, or Mermaid errors.
