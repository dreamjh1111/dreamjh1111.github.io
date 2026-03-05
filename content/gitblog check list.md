---
title: gitblog check list
description: GitHub Pages + Quartz + GitHub Actions로 블로그를 세팅하며 확인한 체크리스트
date: 2026-03-05
tags:
  - setup
  - quartz
  - github-pages
  - ci-cd
---

# 1. 초기 생성 / 로컬 준비

- 기본 브랜치는 Quartz `v4` 기준으로 운용
- Node/NPM 버전은 공식 문서 기준 사용 (`Node v22`, `npm 10.9.2+`)

# 2. GitHub 저장소 연결

- GitHub에 Public repo 생성 (`README`/`.gitignore`/`LICENSE` 미초기화)
- 저장소명은 `dreamjh1111.github.io`로 생성
- 계정당 기본 Pages 사이트는 1개

![[Pasted image 20260305192407.png]]

![[Pasted image 20260305193508.png]]

- 참고: [GitHub Pages 소개](https://docs.github.com/ko/pages/getting-started-with-github-pages/what-is-github-pages)

![[Pasted image 20260305193536.png]]

# 3. 로컬 세팅 이어서

```zsh
# quartz clone (현재 폴더에 바로 구성)
git clone https://github.com/jackyzha0/quartz.git .

# install
npm i

# initialize (node 22+)
npx quartz create

# remote 설정
git remote set-url origin git@github.com:dreamjh1111/dreamjh1111.github.io.git
git remote set-url upstream https://github.com/jackyzha0/quartz.git
git remote -v

# 첫 push
git add .
git commit -m "Initialize Quartz blog"
git push -u origin v4
```

# 4. GitHub Action 설정

```yml
# .github/workflows/deploy.yml
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
