---
title: 01. Github Blog 시작
description: GitHub Pages + Quartz + GitHub Actions 기반으로 개인 기술 블로그를 시작
date: 2026-03-04
tags:
  - setup
  - quartz
  - github-pages
  - ci-cd
  - ko-kr
---

GitHub Pages + Quartz 구성으로 블로그 구축 방법 

# 1. 초기 생성 / 로컬 준비

- 기본 브랜치: `v4`
- 권장 런타임: `Node v22`, `npm 10.9.2+`

```zsh
node -v
npm -v
```

# 2. GitHub 저장소 연결

- GitHub에 Public 저장소 생성
- 저장소명: `dreamjh1111.github.io`
- 생성 시 `README`/`.gitignore`/`LICENSE` 자동 생성 끄기

![[Pasted image 20260305192407.png]]
![[Pasted image 20260305193508.png]]
![[Pasted image 20260305193536.png]]

참고: [GitHub Pages 소개](https://docs.github.com/ko/pages/getting-started-with-github-pages/what-is-github-pages)

# 3. 로컬 세팅 이어서 (정리/마무리)

```zsh
# 현재 폴더에서 Quartz 구성
git clone https://github.com/jackyzha0/quartz.git .
npm i
npx quartz create

# 원격 설정 (내 저장소 + upstream)
git remote set-url origin git@github.com:dreamjh1111/dreamjh1111.github.io.git
git remote set-url upstream https://github.com/jackyzha0/quartz.git
git remote -v

# 첫 배포 커밋
git add .
git commit -m "Initialize Quartz blog"
git push -u origin v4
```

체크 포인트:

- `origin`은 내 저장소를 가리키는지
- `upstream`은 `jackyzha0/quartz`를 가리키는지
- `v4` 브랜치 push 후 Actions가 자동 실행되는지

# 4. GitHub Actions 설정 정리

배포용 워크플로우는 `.github/workflows/deploy.yml` 하나만 유지.

```yml
name: Deploy Quartz site to GitHub Pages

on:
  push:
    branches:
      - v4
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Build Quartz
        run: npx quartz build

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: public

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

추가 확인:

- `Settings > Pages > Source`를 `GitHub Actions`로 설정
- 배포 성공 후 `https://dreamjh1111.github.io` 접속 확인

# 5. 한국어 + Jayden Blog 설정 반영

`quartz.config.ts`에서 아래 항목 적용:

- `pageTitle`: `Jayden Tech Blog`
- `locale`: `ko-KR`
- `baseUrl`: `dreamjh1111.github.io`
- 기본 테마: 다크 모드 기본값 (`DefaultDarkMode`)

`quartz.layout.ts`에서 푸터 GitHub 링크를 내 저장소로 연결:

- `https://github.com/dreamjh1111/dreamjh1111.github.io`

# 마무리

이제 글 작성 후 `git push`만 하면 GitHub Actions를 통해 자동 배포됩니다.

다음 단계는 간단합니다.

1. 새 글 작성
2. 태그/설명(frontmatter) 점검
3. 커밋/푸시
4. Actions 성공 확인

이 루틴만 유지하면 안정적으로 블로그를 운영할 수 있습니다.
