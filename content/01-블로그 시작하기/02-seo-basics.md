---
title: 02. SEO란 무엇이고 어떻게 최적화할까
description: 검색엔진이 페이지를 발견/이해/평가하는 원리와 실무 SEO 최적화 방법 정리
socialDescription: Google 공식 문서와 국내외 기술블로그 사례를 바탕으로 SEO 핵심 개념과 적용법을 정리
date: 2026-03-06
tags:
  - seo
  - technical-seo
  - search-console
  - content-strategy
  - ko-kr
---

SEO(Search Engine Optimization)는 검색엔진이 내 페이지를 더 잘 발견하고, 이해하고, 적절한 검색어에서 노출하도록 만드는 작업이다.

# 1. SEO는 무엇을 최적화하는가

SEO는 단순히 "상위노출 요령"이 아니라 아래 3단계를 높이는 일이다. [^1]

1. Crawling: 검색엔진이 URL을 발견하고 방문할 수 있는가
2. Indexing: 페이지 내용을 정확히 이해하고 색인할 수 있는가
3. Serving/Ranking: 사용자 검색 의도에 맞게 결과로 노출될 가치가 있는가

즉, 기술(크롤링/인덱싱) + 콘텐츠(의도 충족) + 경험(성능/신뢰)을 같이 관리해야 한다.

# 2. SEO가 동작하는 원리 (Google 기준)

Google의 검색 동작 원리는 아래와 같다. [^1]

- 검색엔진은 링크, 사이트맵 등을 통해 URL을 수집한다.
- 수집한 페이지의 HTML, 메타데이터, 링크 구조를 분석한다.
- 문서 주제, 품질, 최신성, 중복 여부를 평가해 색인한다.
- 검색어가 들어오면 의도/문맥(언어, 기기, 지역)에 맞는 페이지를 정렬해서 보여준다.

핵심 포인트:

- 검색엔진이 읽기 쉬운 구조가 먼저다. [^2]
- 이후에 클릭률(CTR), 체류/이탈 같은 사용자 반응이 장기적으로 품질 신호가 된다.

# 3. 유명한 SEO 기법 (실무에서 많이 쓰는 것)

## 3-1. 기술 SEO

- `sitemap.xml` 제공: 크롤러의 URL 발견을 돕는다. [^2]
- `robots.txt` 정리: 크롤링 제어 경계를 명확히 한다. [^3]
- canonical 설정: 중복 URL 신호를 대표 URL로 통합한다. [^2]
- 구조화 데이터(JSON-LD): 글/브레드크럼 의미를 기계가 더 잘 이해하게 한다. [^2]
- Core Web Vitals 개선: LCP/INP/CLS를 안정화해 UX 신호를 개선한다. [^5]

## 3-2. 온페이지 SEO

- title: 검색 의도 + 핵심 키워드 + 문서 가치가 들어가야 한다. [^6]
- meta description: 클릭 이유를 짧고 명확하게 제공한다. [^2]
- H1/H2/H3: 제목 계층으로 문서 구조를 명확히 한다. [^2]
- 내부 링크: 관련 글끼리 연결해 주제 클러스터를 만든다.
- 이미지 alt/text: 비주얼 정보도 검색엔진이 해석 가능하게 만든다. [^2]

## 3-3. 운영 SEO

- Search Console로 색인/성능/쿼리 데이터를 본다.
- 제목/설명/구조를 실험하고 CTR 변화를 측정한다. [^6]
- 잘 노출되는 주제를 중심으로 연관 문서를 확장한다.

# 4. 기술블로그에서 배울 점

대표적으로 대형 서비스들은 SEO를 "실험 가능한 엔지니어링 문제"로 다룬다.

## 4-1. 해외 사례

- **Etsy**: title tag 개선을 A/B 테스트로 검증하고, 짧은 title tag가 더 높은 유입을 만든다는 결론을 실험으로 도출했다. [^6]
- **Etsy**: 다국어 UGC 환경에서 `de.etsy.com` 같은 언어별 서브도메인과 canonical 태그를 활용해 중복 콘텐츠 문제를 해결했다. [^7]
- **Vercel/MERJ**: 10만 건 이상의 Googlebot fetch를 분석해, Google이 JavaScript 콘텐츠를 렌더링/인덱싱할 수 있지만 대규모 사이트(1만+ 페이지)에서는 크롤 버짓에 영향을 줄 수 있음을 확인했다. SSR/SSG로 주요 SEO 태그를 초기 HTML에 포함하는 것을 권장한다. [^8]

## 4-2. 국내 사례

- **당근(Karrot)**: 글로벌 웹사이트(daangn.com)를 Remix 기반으로 리뉴얼하면서 SEO를 핵심 목표로 설정했다. "used sofa in Toronto" 같은 지역 기반 검색에서 상위 노출을 달성하기 위해 콘텐츠 중심 웹사이트 구조를 설계하고, 내부 SEO 관리 도구(Jampot)를 개발해 체계적으로 운영했다. [^9]
- **국내 기술블로그 공통**: 네이버 D2, 우아한형제들, 카카오 등 대형 기술블로그는 자체 도메인에서 SSR/SSG 기반 정적 사이트를 운영하며, 구조화된 메타데이터와 sitemap을 기본으로 갖춘다.

## 4-3. 공통점

- 감이 아니라 데이터(노출, CTR, 색인율, 쿼리)를 기준으로 결정
- 한 번 세팅하고 끝이 아니라 지속 개선 루프 운영

# 5. 네이버 검색 환경 참고

한국에서 블로그를 운영한다면 Google뿐 아니라 네이버 검색도 고려해야 한다.

- 네이버 크롤봇 이름은 **Yeti**이며, robots.txt에서 별도로 허용 설정이 필요할 수 있다.
- **네이버 서치어드바이저**(searchadvisor.naver.com)는 Google Search Console과 유사한 역할을 한다. 사이트 등록, 크롤링/색인 현황, 인기 검색어, CTR 등을 모니터링할 수 있다.
- 네이버는 자체 AI 검색 기술을 적용하고 있으므로, 콘텐츠 품질과 구조화된 마크업이 점점 더 중요해지고 있다.

# 6. 이 블로그(Quartz)에서 바로 적용할 항목

현재 구조 기준으로 우선순위를 잡으면 아래 순서가 효율적이다.

1. 기본 색인 기반
- sitemap/rss 유지 확인
- robots.txt 추가 (Google/Naver Yeti 허용)
- 깨진 내부 링크 정리

2. 메타데이터 표준화
- 모든 글에 title/description/socialDescription/date/tags 작성
- 제목 규칙 통일 (예: `문서 제목 | Jayden Tech Blog`)

3. 검색 노출 품질 강화
- canonical 태그 검토
- 대표 OG 이미지/문서별 social image 정리
- Google Search Console + 네이버 서치어드바이저 등록 및 색인 요청

4. 성능/경험 개선
- 이미지 최적화(webp, 용량 점검)
- Core Web Vitals 모니터링

# 7. 마무리

SEO는 "검색엔진을 속이는 기술"이 아니라, 검색엔진과 사용자가 모두 이해하기 쉬운 문서와 사이트를 만드는 작업이다. [^2]

블로그 초기에는 완벽한 테크닉보다:

1. 정확한 메타데이터
2. 끊기지 않는 내부 링크
3. 검색 의도에 맞는 꾸준한 글 발행

이 3가지를 먼저 안정적으로 가져가는 것이 가장 효과적이다.

# 참고 자료

[^1]: Google Search Central: [How Search Works](https://developers.google.com/search/docs/fundamentals/how-search-works) — 크롤링/인덱싱/서빙 3단계 구조 설명
[^2]: Google Search Central: [SEO Starter Guide](https://developers.google.com/search/docs/fundamentals/seo-starter-guide) — 메타데이터, 구조화 데이터, 내부 링크, 이미지 alt 등 기본 SEO 가이드
[^3]: Google Search Central: [Search Essentials](https://developers.google.com/search/docs/advanced/guidelines/webmaster-guidelines) — 웹마스터 가이드라인, robots.txt 운용 원칙
[^4]: Google Search Central: [JavaScript SEO basics](https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics) — JS 렌더링 환경에서의 크롤링/인덱싱 주의점
[^5]: Google Search Central: [Core Web Vitals and Search](https://developers.google.com/search/docs/appearance/core-web-vitals) — LCP/INP/CLS 지표와 검색 순위 관계
[^6]: Etsy Engineering: [SEO Title Tag Optimization](https://www.etsy.com/codeascraft/seo-title-tag-optimization) — title tag A/B 테스트 실험 설계와 인과 추론 방법론
[^7]: Etsy Engineering: [Multilingual User Generated Content and SEO](https://www.etsy.com/codeascraft/multilingual-user-generated-content-and-seo) — 다국어 UGC 환경에서 서브도메인 + canonical로 중복 콘텐츠 해결
[^8]: Vercel Blog: [How Google handles JavaScript throughout indexing](https://vercel.com/blog/how-google-handles-javascript-throughout-the-indexing-process) — 10만+ Googlebot fetch 분석, JS 렌더링 인덱싱 실험 결과
[^9]: 당근 테크 블로그: [웹사이트의 첫 삽부터 나무를 기르기까지: 당근닷컴 디벨롭의 여정](https://medium.com/daangn/%EC%9B%B9%EC%82%AC%EC%9D%B4%ED%8A%B8%EC%9D%98-%EC%B2%AB-%EC%82%BD%EB%B6%80%ED%84%B0-%EB%82%98%EB%AC%B4%EB%A5%BC-%EA%B8%B0%EB%A5%B4%EA%B8%B0%EA%B9%8C%EC%A7%80-%EB%8B%B9%EA%B7%BC%EB%8B%B7%EC%BB%B4-%EB%94%94%EB%B2%A8%EB%A1%AD%EC%9D%98-%EC%97%AC%EC%A0%95-830cc1a27bf0) — Remix 기반 글로벌 웹사이트 리뉴얼과 SEO 전략
