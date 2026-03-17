---
title: 04. 코드 블럭을 macOS 터미널 스타일로 꾸미기
description: Quartz v4의 코드 블럭에 macOS 트래픽 라이트, 언어 라벨, 다크 테마를 적용하는 과정 기록
socialDescription: Quartz 블로그의 코드 블럭을 macOS 터미널 스타일로 커스터마이징한 전체 과정과 코드
date: "2026-03-06T00:00:04+09:00"
tags:
  - quartz
  - css
  - code-block
  - customization
  - ko-kr
---

기술 블로그에서 코드 블럭은 가장 자주 보이는 요소다. 기본 스타일도 쓸 만하지만, macOS 터미널 스타일로 바꾸면 시각적 완성도가 크게 올라간다.

이 글에서는 Quartz v4의 코드 블럭에 아래 요소를 적용한 과정을 기록한다.

- macOS 트래픽 라이트 (빨/노/초 dots)
- 헤더 바에 언어 라벨 자동 표시
- 코드 영역과 분리된 다크 헤더
- COPY 버튼을 헤더 영역으로 이동
- 라이트/다크 모드 모두에서 일관된 다크 배경

# 1. Quartz 코드 블럭의 기존 구조

## 1-1. 렌더링 파이프라인

Quartz는 **rehype-pretty-code** + **Shiki**를 사용해 빌드 타임에 구문 강조를 처리한다. [^1] 브라우저에서 JS로 하이라이팅하는 방식이 아니라, 빌드 시 VS Code 테마 기반으로 CSS 변수를 생성한다.

빌드된 HTML 구조:

```html
<figure data-rehype-pretty-code-figure>
  <pre data-language="zsh" data-theme="github-light github-dark">
    <code data-language="zsh">
      <span data-line>...</span>
    </code>
  </pre>
</figure>
```

핵심 포인트: `code` 태그의 `data-language` 속성에 언어 정보가 들어있다.

## 1-2. 관련 파일 구조

| 파일 | 역할 |
|------|------|
| `quartz/plugins/transformers/syntax.ts` | Shiki 테마 설정 (github-light/dark) |
| `quartz/styles/base.scss` (425-512줄) | `pre`, `code`, `figure` 기본 스타일 |
| `quartz/styles/syntax.scss` | Shiki CSS 변수 매핑 (라이트/다크 전환) |
| `quartz/components/scripts/clipboard.inline.ts` | 복사 버튼 동적 생성 |
| `quartz/components/styles/clipboard.scss` | 복사 버튼 스타일 |

## 1-3. 기존 복사 버튼 동작

`clipboard.inline.ts`에서 모든 `<pre>` 태그를 찾아 SVG 아이콘 복사 버튼을 `prepend`한다. hover 시에만 나타나는 방식이다.

```typescript
// 기존 코드 (변경 전)
const button = document.createElement("button")
button.className = "clipboard-button"
button.innerHTML = svgCopy
els[i].prepend(button)
```

# 2. 구현: macOS 스타일 헤더 추가

## 2-1. clipboard.inline.ts 수정

기존에는 복사 버튼만 `<pre>` 앞에 넣었다. 이제 **헤더 영역**을 만들고 그 안에 트래픽 라이트 + 언어 라벨 + 복사 버튼을 배치한다.

**파일: `quartz/components/scripts/clipboard.inline.ts`** (전체 교체)

```typescript
const svgCopy =
  '<svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true"><path fill-rule="evenodd" d="M0 6.75C0 5.784.784 5 1.75 5h1.5a.75.75 0 010 1.5h-1.5a.25.25 0 00-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 00.25-.25v-1.5a.75.75 0 011.5 0v1.5A1.75 1.75 0 019.25 16h-7.5A1.75 1.75 0 010 14.25v-7.5z"></path><path fill-rule="evenodd" d="M5 1.75C5 .784 5.784 0 6.75 0h7.5C15.216 0 16 .784 16 1.75v7.5A1.75 1.75 0 0114.25 11h-7.5A1.75 1.75 0 015 9.25v-7.5zm1.75-.25a.25.25 0 00-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 00.25-.25v-7.5a.25.25 0 00-.25-.25h-7.5z"></path></svg>'
const svgCheck =
  '<svg aria-hidden="true" height="16" viewBox="0 0 16 16" version="1.1" width="16" data-view-component="true"><path fill-rule="evenodd" fill="rgb(63, 185, 80)" d="M13.78 4.22a.75.75 0 010 1.06l-7.25 7.25a.75.75 0 01-1.06 0L2.22 9.28a.75.75 0 011.06-1.06L6 10.94l6.72-6.72a.75.75 0 011.06 0z"></path></svg>'

document.addEventListener("nav", () => {
  const els = document.getElementsByTagName("pre")
  for (let i = 0; i < els.length; i++) {
    const codeBlock = els[i].getElementsByTagName("code")[0]
    if (codeBlock) {
      const source = (
        codeBlock.dataset.clipboard
          ? JSON.parse(codeBlock.dataset.clipboard)
          : codeBlock.innerText
      ).replace(/\n\n/g, "\n")

      // data-language 속성에서 언어 정보 추출
      const lang = codeBlock.getAttribute("data-language") ?? ""

      // macOS 스타일 헤더 생성
      const header = document.createElement("div")
      header.className = "code-header"

      // 트래픽 라이트 (빨/노/초)
      const trafficLights = document.createElement("span")
      trafficLights.className = "traffic-lights"
      trafficLights.innerHTML =
        '<span class="dot dot-red"></span>' +
        '<span class="dot dot-yellow"></span>' +
        '<span class="dot dot-green"></span>'

      // 언어 라벨
      const langLabel = document.createElement("span")
      langLabel.className = "code-lang"
      langLabel.textContent = lang.toUpperCase()

      header.appendChild(trafficLights)
      header.appendChild(langLabel)

      // 복사 버튼 (헤더 안으로 이동)
      const button = document.createElement("button")
      button.className = "clipboard-button"
      button.type = "button"
      button.innerHTML = svgCopy
      button.ariaLabel = "Copy source"

      function onClick() {
        navigator.clipboard.writeText(source).then(
          () => {
            button.blur()
            button.innerHTML = svgCheck
            setTimeout(() => {
              button.innerHTML = svgCopy
              button.style.borderColor = ""
            }, 2000)
          },
          (error) => console.error(error),
        )
      }
      button.addEventListener("click", onClick)
      window.addCleanup(() => button.removeEventListener("click", onClick))
      header.appendChild(button)

      // pre 태그 맨 앞에 헤더 삽입
      els[i].prepend(header)
    }
  }
})
```

변경 포인트:

1. `codeBlock.getAttribute("data-language")` — rehype-pretty-code가 생성한 언어 속성을 읽어서 자동으로 표시
2. `code-header` div 안에 트래픽 라이트 + 언어 라벨 + 복사 버튼을 묶음
3. 기존처럼 `els[i].prepend(header)`로 `<pre>` 맨 앞에 삽입

## 2-2. clipboard.scss 수정

복사 버튼이 독립적이었던 기존 스타일을 헤더 영역 안으로 통합한다.

**파일: `quartz/components/styles/clipboard.scss`** (전체 교체)

```scss
/* macOS-style code block header */
.code-header {
  display: flex;
  align-items: center;
  padding: 0.5rem 0.8rem;
  background: #2d2d30;
  border-bottom: 1px solid #3e3e42;
  border-radius: 10px 10px 0 0;
  position: sticky;
  top: 0;
  z-index: 1;
}

.traffic-lights {
  display: flex;
  gap: 6px;
}

.dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.dot-red { background: #ff5f56; }
.dot-yellow { background: #ffbd2e; }
.dot-green { background: #27c93f; }

.code-lang {
  flex: 1;
  text-align: right;
  font-family: var(--codeFont);
  font-size: 0.75rem;
  color: #989b9f;
  padding-right: 0.5rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.clipboard-button {
  display: flex;
  align-items: center;
  padding: 0.2rem 0.5rem;
  color: #989b9f;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 4px;
  opacity: 0;
  transition: opacity 0.2s, background 0.2s;
  cursor: pointer;
  flex-shrink: 0;

  & > svg { fill: #989b9f; }
  &:hover {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(255, 255, 255, 0.25);
  }
  &:focus { outline: 0; }
}

pre:hover .clipboard-button {
  opacity: 1;
}
```

각 요소의 역할:

| 셀렉터 | 역할 |
|---------|------|
| `.code-header` | 헤더 바 — `#2d2d30` 배경으로 코드 영역(`#1e1e1e`)과 분리 |
| `.traffic-lights` | 빨/노/초 dot 컨테이너 — `gap: 6px`로 간격 |
| `.dot-red/yellow/green` | macOS 창 버튼 색상 (#ff5f56, #ffbd2e, #27c93f) |
| `.code-lang` | 우측 정렬, `flex: 1`로 남은 공간 차지 |
| `.clipboard-button` | hover 시에만 나타나는 반투명 버튼 |

# 3. 구현: 코드 영역 스타일 변경

## 3-1. base.scss의 pre 스타일 수정

기존의 `border: 1px solid var(--lightgray)` 스타일을 제거하고 macOS 윈도우 느낌으로 변경한다.

**파일: `quartz/styles/base.scss`** (pre 블럭 수정)

```scss
pre {
  font-family: var(--codeFont);
  padding: 0;                          // 헤더가 패딩 담당
  border-radius: 10px;                 // 더 둥근 코너
  overflow: hidden;                    // 헤더 라운드 유지
  border: none;                        // 테두리 제거
  position: relative;
  background: #1e1e1e;                 // 항상 다크 배경
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.15);  // 부드러운 그림자
  margin: 1.5em 0;                     // 상하 여백

  &:has(> code.mermaid) {
    border: none;
    background: transparent;
    box-shadow: none;
  }

  & > code {
    background: none;
    padding: 0;
    font-size: 0.85rem;
    counter-reset: line;
    counter-increment: line 0;
    display: grid;
    padding: 0.8rem 0;                // 코드 상하 패딩 확대
    overflow-x: auto;

    & > [data-line] {
      padding: 0 0.8rem;              // 좌우 패딩 확대
      // ... (라인 넘버, 하이라이트 등 기존 유지)
    }
  }
}
```

주요 변경:

| 속성 | 변경 전 | 변경 후 | 이유 |
|------|---------|---------|------|
| `padding` | `0 0.5rem` | `0` | 헤더 div가 자체 패딩 관리 |
| `border-radius` | `5px` | `10px` | macOS 윈도우 스타일 |
| `overflow` | `auto` | `hidden` | 헤더 라운드 코너 유지 |
| `border` | `1px solid var(--lightgray)` | `none` | 테두리 대신 그림자 |
| `background` | 테마 의존 | `#1e1e1e` | 항상 다크 배경 강제 |
| `box-shadow` | 없음 | `0 4px 24px rgba(0,0,0,0.15)` | 부드러운 떠 있는 효과 |

## 3-2. syntax.scss 수정 — 코드 블럭 항상 다크 테마 강제

코드 블럭 배경이 항상 다크이므로, 라이트 모드에서도 코드 색상은 다크 테마를 사용해야 한다.

**파일: `quartz/styles/syntax.scss`** (하단에 추가)

```scss
/* macOS-style: 코드 블럭은 항상 다크 테마 색상 사용 */
pre {
  code[data-theme*=" "] {
    color: var(--shiki-dark);
    background-color: transparent;
  }

  code[data-theme*=" "] span {
    color: var(--shiki-dark);
  }
}
```

이 규칙이 없으면 라이트 모드에서 다크 배경 위에 밝은 색상의 코드가 표시되어 가독성이 떨어진다.

# 4. 적용 전후 비교

## 4-1. Before — 기본 스타일

배포된 사이트(`dreamjh1111.github.io`)에서 캡처한 변경 전 코드 블럭이다.

![[Pasted image 20260306154303.png]]

- 테두리 없는 단순 다크 배경
- 헤더 영역 없음
- 언어 정보 표시 없음
- 복사 버튼은 있지만 위치가 코드 영역 안에 직접 배치

## 4-2. After — macOS 터미널 스타일

로컬 서버(`localhost:8080`)에서 캡처한 변경 후 코드 블럭이다.

![[Pasted image 20260306154353.png]]

- macOS 트래픽 라이트 (빨/노/초) 추가
- 헤더 바에 언어 라벨 (TYPESCRIPT, TSX, JSON 등) 자동 표시
- 헤더(`#2d2d30`)와 코드 영역(`#1e1e1e`)의 시각적 분리
- 복사 버튼이 헤더 우측으로 이동
- `border-radius: 10px`과 `box-shadow`로 macOS 윈도우 느낌

# 5. 변경 내역 정리

## 5-1. 변경 파일 요약

| 파일 | 변경 유형 | 내용 |
|------|-----------|------|
| `quartz/components/scripts/clipboard.inline.ts` | 수정 | 헤더 영역(트래픽 라이트 + 언어 라벨 + 복사 버튼) 동적 생성 |
| `quartz/components/styles/clipboard.scss` | 수정 | 헤더/트래픽 라이트/복사 버튼 스타일 |
| `quartz/styles/base.scss` | 수정 | pre 태그 다크 배경, 라운드 코너, 그림자 |
| `quartz/styles/syntax.scss` | 수정 | 코드 블럭 항상 다크 테마 색상 강제 |

## 5-2. 적용된 스타일 요소

- 트래픽 라이트: 빨(`#ff5f56`), 노(`#ffbd2e`), 초(`#27c93f`) — macOS 표준 색상
- 헤더 배경: `#2d2d30` (VS Code 타이틀 바 색상)
- 코드 배경: `#1e1e1e` (VS Code 편집기 기본 색상)
- 구분선: `#3e3e42` (헤더-코드 영역 경계)
- 언어 라벨: `data-language` 속성에서 자동 추출, 대문자 변환
- 복사 버튼: hover 시 나타나는 반투명 스타일

## 5-3. 지원 범위

- 모든 fenced code block (````언어명` 형식)에 자동 적용
- 라이트/다크 모드 모두에서 코드 블럭은 항상 다크 배경
- `mermaid` 다이어그램은 기존대로 투명 배경 유지
- 기존 Quartz 기능(라인 넘버, 라인 하이라이트, 코드 타이틀)과 호환

# 5. 참고 자료

[^1]: Quartz: [Syntax Highlighting](https://quartz.jzhao.xyz/features/syntax-highlighting) — rehype-pretty-code + Shiki 기반 빌드 타임 구문 강조
[^2]: Quartz: [SyntaxHighlighting Plugin](https://quartz.jzhao.xyz/plugins/SyntaxHighlighting) — 테마 설정, syntax.scss 커스터마이징 안내
[^3]: CodeHubly: [Code Blocks with Syntax Highlighting in 3 Different Styles](https://www.codehubly.com/2025/10/code-blocks-with-syntax-highlighting-in.html) — macOS 스타일 코드블럭 HTML/CSS/JS 전체 구현
[^4]: CSS-Tricks: [Code blocks, but better](https://css-tricks.com/code-blocks-but-better/) — 코드 블럭 UX 개선 패턴 (copy, title, highlight)
[^5]: CodePen: [Mac OS X Traffic Lights](https://codepen.io/atdrago/pen/yezrBR) — 트래픽 라이트 CSS 구현
[^6]: CodePen: [CSS3 Mac Terminal](https://codepen.io/mxexo/pen/KKwPGN) — macOS 터미널 전체 CSS 구현
