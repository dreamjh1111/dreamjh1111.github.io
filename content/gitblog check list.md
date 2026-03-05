---
title: GitBlog 체크리스트 (Quartz + GitHub Pages)
description: Quartz 공식 방식으로 블로그를 세팅하고 GitHub Actions로 배포할 때 필요한 핵심 체크리스트
date: 2026-03-05
tags:
  - setup
  - quartz
  - github-pages
  - ci-cd
socialDescription: Quartz + GitHub Pages + GitHub Actions 배포 체크리스트
---

GitBlog를 처음 만들 때 실제로 막히기 쉬운 부분만 남겨 정리한 최종 체크리스트입니다.

## 1) 초기 생성 / 로컬 준비

- Node `v22` 이상 확인 (`node -v`)
- Quartz 공식 저장소로 시작

```bash
git clone https://github.com/jackyzha0/quartz.git .
npm i
npx quartz create
```

## 2) GitHub 저장소 준비

- GitHub에서 `dreamjh1111.github.io` 저장소 생성 (Public)
- 빈 저장소로 생성 (`README`, `.gitignore`, `LICENSE` 자동 생성 끔)

## 3) 원격(remote) 연결 정리

```bash
git remote set-url origin git@github.com:dreamjh1111/dreamjh1111.github.io.git
git remote set-url upstream https://github.com/jackyzha0/quartz.git
git remote -v
```

확인 포인트:

- `origin` -> 내 저장소
- `upstream` -> `jackyzha0/quartz`

## 4) Quartz 사이트 기본 설정

`quartz.config.ts`에서 최소 3가지를 먼저 맞춤:

- `pageTitle`: `Jayden Tech Blog`
- `baseUrl`: `dreamjh1111.github.io`
- 기본 테마: 다크 모드 우선(Default Dark)

## 5) GitHub Actions 배포

- `.github/workflows/deploy.yml` 1개만 유지
- 트리거 브랜치(`v4`)로 push 시 자동 배포
- `Settings > Pages > Source`를 `GitHub Actions`로 설정

## 6) 첫 배포 검증

- Actions에서 `build` + `deploy` 성공 확인
- 사이트 접속: `https://dreamjh1111.github.io`
- 홈/링크/검색/태그 페이지 정상 동작 확인

## 7) 운영 루틴

- 새 글 작성 -> `git add/commit/push`
- push 후 Actions 성공 확인
- 링크 깨짐, frontmatter 누락, 태그 누락 점검

---

다음 글부터는 문서 1개당 주제 1개 원칙으로 운영.
