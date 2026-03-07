---
title: "05. DB 없이 댓글 기능 붙이기: Giscus 적용"
description: "정적 블로그에서 DB 서버 없이 댓글 기능을 운영하기 위해 Giscus를 선택한 이유, 원리, 적용 방법을 정리한다."
socialDescription: "GitHub Discussions 기반 댓글 시스템 Giscus의 선택 배경과 실제 적용 코드를 정리한 글."
date: 2026-03-07
tags:
  - quartz
  - comments
  - giscus
  - github-discussions
  - blog
  - ko-kr
---

정적 블로그를 GitHub Pages로 운영하면 이런 고민이 생긴다.

- 댓글을 위해 서버와 DB를 따로 만들까?
- 아니면 외부 댓글 시스템을 붙일까?

이번 글에서는 **DB를 직접 운영하지 않고 Giscus를 선택한 이유**, **동작 원리**, **실제 적용 방법**을 정리한다.

# 1. 왜 DB 방식 대신 Giscus를 선택했나

일반적인 댓글 시스템을 직접 만들면 아래가 필요하다.

1. 댓글 저장 DB
2. API 서버
3. 로그인과 권한 처리
4. 스팸 대응
5. 운영/백업

개인 블로그에는 이 운영 비용이 크다. 반면 Giscus는 댓글 저장소로 GitHub Discussions를 사용하므로, 인프라 부담을 크게 줄일 수 있다.

| 항목 | 자체 DB 댓글 | Giscus |
|---|---|---|
| 인프라 운영 | 필요 | 거의 없음 |
| 인증/권한 | 직접 구현 | GitHub 계정 기반 |
| 댓글 저장 | 내가 운영하는 DB | GitHub Discussions |
| 단점 | 개발/운영 복잡 | GitHub 로그인 필요 |

# 2. Giscus는 어떤 원리로 동작하나

Giscus는 페이지에 삽입된 스크립트가 현재 페이지와 연결된 Discussion을 찾아서 댓글 UI를 띄운다.

동작 흐름:

1. 페이지에서 `https://giscus.app/client.js`를 로드한다.
2. `data-mapping` 규칙(예: `pathname`)으로 페이지를 Discussion에 매핑한다.
3. Discussion이 없으면 설정된 카테고리에 새 스레드를 만든다.
4. 댓글/반응은 GitHub Discussions에 저장된다.

# 3. 커뮤니티 적용기에서 많이 보이는 패턴 (오마주)

여러 적용기에서 공통으로 강조하는 포인트는 거의 같다.

1. 저장소는 Public 이어야 한다.
2. Discussions 기능을 켜야 한다.
3. giscus GitHub App 설치가 필요하다.
4. 카테고리는 `Announcements`를 많이 사용한다.
5. 매핑은 `pathname`을 많이 사용한다.

아래 이미지는 이 흐름을 그대로 보여주는 화면이다.

## 저장소 설정

![[giscus-repo.png]]

## Discussion 카테고리 설정

![[giscus-discussion.png]]

## 최종 script 값 확인

![[giscus-results.png]]

## 실제 댓글 UI 예시

![[giscus-example.png]]

# 4. 이 블로그에 실제로 적용한 코드

`quartz.layout.ts`의 `afterBody`에 댓글 컴포넌트를 추가했다.

```ts
const giscusConfig = {
  repo: "dreamjh1111/dreamjh1111.github.io" as const,
  repoId: "R_kgDORfDPig",
  category: "Announcements",
  categoryId: "DIC_kwDORfDPis4C34mu",
  lang: "ko",
}

afterBody: [
  Component.ConditionalRender({
    component: Component.Comments({
      provider: "giscus",
      options: {
        repo: giscusConfig.repo,
        repoId: giscusConfig.repoId,
        category: giscusConfig.category,
        categoryId: giscusConfig.categoryId,
        lang: giscusConfig.lang,
        mapping: "pathname",
        strict: false,
        reactionsEnabled: true,
        inputPosition: "bottom",
      },
    }),
    condition: (page) =>
      page.fileData.slug !== "index" &&
      page.fileData.slug !== "404" &&
      !page.fileData.slug.startsWith("tags/") &&
      !page.fileData.slug.endsWith("/index"),
  }),
]
```

노출 조건을 둔 이유:

- 홈/태그/폴더 목록 페이지에는 댓글이 필요하지 않다.
- 포스트 상세 페이지에서만 댓글을 보여주면 UX가 더 깔끔하다.

# 5. 적용 후 확인 체크리스트

1. 포스트 하단에 댓글 박스가 보이는지
2. 로그인 후 댓글 작성이 되는지
3. GitHub Discussions에 스레드가 생성되는지
4. 모바일에서 입력창이 정상 동작하는지

# 참고 자료

## 공식 문서

- Giscus: https://giscus.app/ko
- Giscus GitHub: https://github.com/giscus/giscus
- GitHub Docs (Discussions 활성화): https://docs.github.com/ko/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/enabling-or-disabling-github-discussions-for-a-repository
- GitHub Docs (Discussions 카테고리): https://docs.github.com/ko/discussions/managing-discussions-for-your-community/managing-categories-for-discussions-in-your-repository
- Quartz Docs (Comments): https://quartz.jzhao.xyz/features/comments

## 커뮤니티 글

- HAHWUL: https://www.hahwul.com/2023/05/20/add-comments-with-giscus/
- Damdae: https://damdae00.tistory.com/117
- 코딩일지: https://limmmee-ing.tistory.com/117
- Jinny Archive: https://ji-studio.tistory.com/entry/Jekyll-%EB%B8%94%EB%A1%9C%EA%B7%B8-%EA%B0%9C%EB%B0%9C-log-7-giscus-%EB%8C%93%EA%B8%80-%EC%8B%9C%EC%8A%A4%ED%85%9C-%EB%8F%84%EC%9E%85%EA%B8%B0