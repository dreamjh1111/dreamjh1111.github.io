---
title: 03. Quartz 블로그에 SEO 최적화 적용하기
description: Quartz v4 블로그에 robots.txt, canonical, JSON-LD 구조화 데이터, 메타 태그를 직접 적용한 과정 기록
socialDescription: Quartz 정적 블로그에 실무 SEO를 적용한 전체 과정과 코드 변경 내역 정리
date: 2026-03-06
tags:
  - seo
  - technical-seo
  - quartz
  - json-ld
  - ko-kr
---

[[01-blog-setup/02-seo-basics|이전 글]]에서 SEO의 원리와 기법을 정리했다. 이 글에서는 그 내용을 바탕으로 이 블로그(Quartz v4 + GitHub Pages)에 **실제로 적용한 작업**을 코드 단위로 기록한다.

# 1. 적용 전 현황 진단

Quartz v4 기본 설치 상태에서 SEO 관련 요소를 점검했다.

| 항목 | 상태 | 위치 |
|------|------|------|
| sitemap.xml | 이미 활성 | `quartz.config.ts` — `enableSiteMap: true` |
| RSS feed | 이미 활성 | `quartz.config.ts` — `enableRSS: true` |
| OG 이미지 (per-page) | 이미 활성 | `quartz.config.ts` — `CustomOgImages()` |
| meta description | 이미 있음 | `Head.tsx` — frontmatter에서 자동 생성 |
| OG/Twitter 메타 태그 | 이미 있음 | `Head.tsx` — og:title, twitter:card 등 |
| lang 속성 | 이미 있음 | `renderPage.tsx` — locale에서 `ko` 추출 |
| **robots.txt** | **없음** | 파일 자체가 미존재 |
| **canonical 태그** | **없음** | `Head.tsx`에 미포함 |
| **구조화 데이터 (JSON-LD)** | **없음** | `Head.tsx`에 미포함 |
| **pageTitleSuffix** | **빈 문자열** | `quartz.config.ts` — `""` |

Quartz는 기본적으로 sitemap, RSS, OG 메타 태그를 잘 갖추고 있지만, **robots.txt, canonical, JSON-LD**는 직접 추가해야 한다.

# 2. robots.txt 추가

## 2-1. 왜 필요한가

`robots.txt`는 크롤러에게 사이트의 접근 규칙을 알려주는 파일이다. [^1] 없어도 크롤링은 되지만, 명시적으로 제공하면:

- 크롤러가 sitemap 위치를 즉시 파악할 수 있다
- 불필요한 경로(static 리소스 등)의 크롤링을 제어할 수 있다
- 네이버 Yeti 크롤러 등 특정 봇에 대한 허용을 명시할 수 있다

## 2-2. Quartz 구조 분석

Quartz의 파일 출력 구조를 먼저 이해해야 한다.

- `quartz/static/` 폴더 → 빌드 시 `public/static/`으로 복사 (`static.ts` 에미터)
- 따라서 `quartz/static/robots.txt`로 만들면 `public/static/robots.txt`가 되어 **루트가 아니다**
- `robots.txt`는 반드시 사이트 루트(`/robots.txt`)에 있어야 한다

해결 방법: **CNAME 에미터와 동일한 패턴**으로 루트에 파일을 생성하는 커스텀 에미터를 만든다.

`quartz/plugins/emitters/cname.ts`가 `write()` 헬퍼를 사용해 `CNAME` 파일을 루트에 쓰는 것을 참고했다.

## 2-3. 구현

**파일: `quartz/plugins/emitters/robotsTxt.ts`** (신규 생성)

```typescript
import { QuartzEmitterPlugin } from "../types"
import { write } from "./helpers"
import { FullSlug } from "../../util/path"

export const RobotsTxt: QuartzEmitterPlugin = () => ({
  name: "RobotsTxt",
  async emit(ctx) {
    const baseUrl = ctx.cfg.configuration.baseUrl ?? ""
    const content = [
      "User-agent: *",
      "Allow: /",
      "",
      "User-agent: Yeti",
      "Allow: /",
      "",
      `Sitemap: https://${baseUrl}/sitemap.xml`,
    ].join("\n")

    const path = await write({
      ctx,
      content,
      slug: "robots" as FullSlug,
      ext: ".txt",
    })
    return [path]
  },
  async *partialEmit() {},
})
```

핵심 포인트:
- `slug: "robots"`, `ext: ".txt"` → 빌드 시 `public/robots.txt`로 출력
- `User-agent: Yeti` → 네이버 크롤러 명시적 허용 [^2]
- `Sitemap` 지시어 → 크롤러가 sitemap 위치를 자동 발견

**파일: `quartz/plugins/emitters/index.ts`** (export 추가)

```typescript
// 기존 export들 아래에 추가
export { RobotsTxt } from "./robotsTxt"
```

**파일: `quartz.config.ts`** (플러그인 등록)

```typescript
emitters: [
  // ... 기존 에미터들
  Plugin.CustomOgImages(),
  Plugin.RobotsTxt(),  // 추가
],
```

## 2-4. 빌드 결과 확인

```
$ npx quartz build
$ cat public/robots.txt

User-agent: *
Allow: /

User-agent: Yeti
Allow: /

Sitemap: https://dreamjh1111.github.io/sitemap.xml
```

# 3. canonical 태그 추가

## 3-1. 왜 필요한가

canonical 태그는 검색엔진에게 "이 페이지의 대표 URL은 이것이다"라고 알려준다. [^3] 동일한 콘텐츠가 여러 URL로 접근 가능할 때(trailing slash, 파라미터 등) 중복 색인을 방지한다.

## 3-2. 기존 상태

`Head.tsx`에 canonical 태그가 없었다. Quartz에서 canonical은 `aliases.ts`의 리다이렉트 HTML에서만 사용되고 있었다.

## 3-3. 구현

**파일: `quartz/components/Head.tsx`** (수정)

```tsx
// import 추가
import { FullSlug, getFileExtension, joinSegments, pathToRoot, simplifySlug } from "../util/path"

// Head 컴포넌트 내부, socialUrl 계산 아래에 추가
const canonicalUrl = cfg.baseUrl
  ? `https://${cfg.baseUrl}/${fileData.slug === "index" ? "" : fileData.slug}`
  : undefined

// <head> 태그 내부, viewport 메타 아래에 추가
{/* Canonical URL */}
{canonicalUrl && <link rel="canonical" href={canonicalUrl} />}
```

## 3-4. 빌드 결과

```html
<link rel="canonical" href="https://dreamjh1111.github.io/01-blog-setup/02-seo-basics"/>
```

index 페이지는 `https://dreamjh1111.github.io/`로, 개별 글은 slug 기반 URL로 정규화된다.

# 4. JSON-LD 구조화 데이터 추가

## 4-1. 왜 필요한가

JSON-LD(Linked Data)는 검색엔진이 페이지의 의미를 기계적으로 이해할 수 있게 하는 구조화 데이터 형식이다. [^4] Google은 이를 기반으로 리치 결과(rich results)를 생성한다.

블로그 글에 적용할 스키마:
- **BlogPosting**: 글의 제목, 설명, 작성일, 수정일, 저자 정보 [^5]
- **BreadcrumbList**: 사이트 내 탐색 경로 [^6]

## 4-2. 구현

**파일: `quartz/components/Head.tsx`** (수정)

BlogPosting 스키마:

```tsx
// import 추가
import { getDate } from "./Date"

// Head 컴포넌트 내부
const datePublished = getDate(cfg, fileData)
const dateModified = fileData.dates?.modified
const slug = fileData.slug ?? ""
const isPost = slug !== "index" && slug !== "404"

const jsonLd = isPost
  ? JSON.stringify({
      "@context": "https://schema.org",
      "@type": "BlogPosting",
      headline: fileData.frontmatter?.title ?? "",
      description: description,
      url: canonicalUrl,
      ...(datePublished && { datePublished: datePublished.toISOString() }),
      ...(dateModified && { dateModified: dateModified.toISOString() }),
      author: {
        "@type": "Person",
        name: "Jayden",
      },
      publisher: {
        "@type": "Organization",
        name: cfg.pageTitle,
      },
      mainEntityOfPage: {
        "@type": "WebPage",
        "@id": canonicalUrl,
      },
    })
  : undefined
```

BreadcrumbList 스키마:

```tsx
const slugParts = slug.split("/").filter(Boolean)
const breadcrumbItems = [
  { name: "Home", url: `https://${cfg.baseUrl}/` },
  ...slugParts.map((part, i) => ({
    name: part,
    url:
      i < slugParts.length - 1
        ? `https://${cfg.baseUrl}/${slugParts.slice(0, i + 1).join("/")}/`
        : undefined,
  })),
]

const breadcrumbJsonLd =
  isPost && slugParts.length > 0
    ? JSON.stringify({
        "@context": "https://schema.org",
        "@type": "BreadcrumbList",
        itemListElement: breadcrumbItems.map((item, i) => ({
          "@type": "ListItem",
          position: i + 1,
          name: item.name,
          ...(item.url && { item: item.url }),
        })),
      })
    : undefined
```

HTML 출력:

```tsx
{/* JSON-LD: BlogPosting */}
{jsonLd && (
  <script type="application/ld+json"
    dangerouslySetInnerHTML={{ __html: jsonLd }} />
)}
{/* JSON-LD: BreadcrumbList */}
{breadcrumbJsonLd && (
  <script type="application/ld+json"
    dangerouslySetInnerHTML={{ __html: breadcrumbJsonLd }} />
)}
```

## 4-3. 빌드 결과

BlogPosting:

```json
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "02. SEO란 무엇이고 어떻게 최적화할까",
  "description": "Google 공식 문서와 국내외 기술블로그 사례를 바탕으로...",
  "url": "https://dreamjh1111.github.io/01-blog-setup/02-seo-basics",
  "datePublished": "2026-03-05T15:00:00.000Z",
  "dateModified": "2026-03-05T15:00:00.000Z",
  "author": { "@type": "Person", "name": "Jayden" },
  "publisher": { "@type": "Organization", "name": "Jayden Tech Blog" },
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "https://dreamjh1111.github.io/01-blog-setup/02-seo-basics"
  }
}
```

BreadcrumbList:

```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "Home", "item": "https://dreamjh1111.github.io/" },
    { "@type": "ListItem", "position": 2, "name": "01-blog-setup", "item": "https://dreamjh1111.github.io/01-blog-setup/" },
    { "@type": "ListItem", "position": 3, "name": "02-seo-basics" }
  ]
}
```

주의: BreadcrumbList의 마지막 항목은 현재 페이지이므로 `item` URL을 생략한다. [^6]

# 5. pageTitleSuffix 설정

## 5-1. 왜 필요한가

검색 결과에서 사이트를 식별할 수 있도록 모든 페이지 제목 뒤에 블로그 이름을 붙인다. Etsy는 title tag를 A/B 테스트해서 최적 형태를 찾았는데, 일반적으로 `페이지 제목 | 사이트 이름` 형식이 표준이다. [^7]

## 5-2. 구현

**파일: `quartz.config.ts`** (수정)

```typescript
// 변경 전
pageTitleSuffix: "",

// 변경 후
pageTitleSuffix: " | Jayden Tech Blog",
```

## 5-3. 빌드 결과

```html
<title>02. SEO란 무엇이고 어떻게 최적화할까 | Jayden Tech Blog</title>
```

이 suffix는 `<title>`, `og:title`, `twitter:title`에 모두 반영된다.

# 6. 적용 결과 종합

## 6-1. 변경 파일 요약

| 파일 | 변경 유형 | 내용 |
|------|-----------|------|
| `quartz/plugins/emitters/robotsTxt.ts` | 신규 생성 | robots.txt 에미터 플러그인 |
| `quartz/plugins/emitters/index.ts` | 수정 | RobotsTxt export 추가 |
| `quartz/components/Head.tsx` | 수정 | canonical 태그, JSON-LD (BlogPosting + BreadcrumbList) 추가 |
| `quartz.config.ts` | 수정 | pageTitleSuffix 설정, RobotsTxt 플러그인 등록 |

## 6-2. 02편 기준 충족 현황

[[01-blog-setup/02-seo-basics|02편]]에서 정리한 "이 블로그에서 바로 적용할 항목"과 대조한다.

**1단계 - 기본 색인 기반**
- sitemap/rss 유지 확인 → 이미 활성 상태
- robots.txt 추가 → **이번에 적용**
- 깨진 내부 링크 정리 → 글 수가 적어 현재 문제 없음

**2단계 - 메타데이터 표준화**
- title/description/socialDescription/date/tags 작성 → 모든 글에 적용 중
- 제목 규칙 통일 → **pageTitleSuffix로 적용**

**3단계 - 검색 노출 품질 강화**
- canonical 태그 검토 → **이번에 적용**
- 대표 OG 이미지/문서별 social image → CustomOgImages로 이미 활성
- Search Console + 서치어드바이저 등록 → 다음 단계에서 진행

**4단계 - 성능/경험 개선**
- 이미지 최적화 → 추후 콘텐츠 증가 시 점검
- Core Web Vitals 모니터링 → 추후 점검

## 6-3. 국내 기술블로그와의 비교

조사한 국내 기술블로그의 SEO 적용 현황과 비교한다.

| 항목 | 토스 (toss.tech) | 이 블로그 (적용 후) |
|------|------------------|---------------------|
| meta description | O | O |
| OG 태그 | O | O |
| Twitter Card | O | O |
| RSS Feed | O | O |
| canonical | X | **O** |
| JSON-LD | X | **O** |
| robots.txt | X (404) | **O** |
| 문서별 OG 이미지 | O | O |

흥미롭게도 토스 기술블로그조차 canonical, JSON-LD, robots.txt가 없었다. 개인 블로그라도 기본기를 갖추면 대형 기술블로그 수준의 SEO 기반은 충분히 확보할 수 있다.

# 7. 다음 단계

이번에 코드 수준의 기술 SEO를 완료했다. 남은 작업:

1. **Google Search Console 등록**: HTML 메타 태그 방식으로 소유권 인증 후 sitemap 제출
2. **네이버 서치어드바이저 등록**: `naverXXXX.html` 파일을 루트에 업로드하고 sitemap/RSS 제출 [^2]
3. **Google Rich Results Test**: 구조화 데이터가 리치 결과 대상인지 검증 [^8]
4. **Lighthouse 측정**: Core Web Vitals 기준으로 성능 베이스라인 확보
5. **콘텐츠 축적**: SEO 기법만으로는 한계가 있고, 검색 의도에 맞는 꾸준한 글 발행이 본질

# 참고 자료

[^1]: Google Search Central: [Search Essentials](https://developers.google.com/search/docs/advanced/guidelines/webmaster-guidelines) — robots.txt 운용 원칙
[^2]: 네이버 서치어드바이저: [GitHub 블로그 등록 방법](https://boyinblue.github.io/002_github_blog/003_naver_search_advisor.html) — Yeti 크롤러, 소유권 인증 과정
[^3]: Google Search Central: [SEO Starter Guide](https://developers.google.com/search/docs/fundamentals/seo-starter-guide) — canonical 태그, 메타데이터 가이드
[^4]: Google Search Central: [Structured Data](https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data) — JSON-LD 구조화 데이터 개요
[^5]: Google Search Central: [Article Structured Data](https://developers.google.com/search/docs/appearance/structured-data/article) — BlogPosting 스키마 필수/권장 속성
[^6]: Google Search Central: [Breadcrumb Structured Data](https://developers.google.com/search/docs/appearance/structured-data/breadcrumb) — BreadcrumbList 스키마 (마지막 항목은 item URL 생략)
[^7]: Etsy Engineering: [SEO Title Tag Optimization](https://www.etsy.com/codeascraft/seo-title-tag-optimization) — title tag A/B 테스트와 최적 형식 도출
[^8]: Google: [Rich Results Test](https://search.google.com/test/rich-results) — 구조화 데이터 검증 도구
