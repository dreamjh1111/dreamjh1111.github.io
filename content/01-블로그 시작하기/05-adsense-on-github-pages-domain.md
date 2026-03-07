---
title: 05. GitHub 기본 도메인(dreamjh1111.github.io)에 Google AdSense 적용하기
description: 커스텀 도메인 없이 GitHub Pages 기본 도메인에 AdSense를 적용하고, ads.txt/검증/점검까지 진행한 구현 기록
socialDescription: Quartz 블로그에 AdSense 설정 객체, head 스크립트 주입, 루트 ads.txt 생성, 배포 후 확인 절차를 적용한 상세 가이드
date: 2026-03-07
draft: true
tags:
  - quartz
  - github-pages
  - adsense
  - blog
  - ko-kr
---

# 왜 기본 도메인으로도 가능한가?

결론부터 말하면 **커스텀 도메인 없이 `dreamjh1111.github.io` 기본 도메인으로도 AdSense 적용은 가능**하다.  
핵심은 "내가 사이트를 제어하고 있다는 점(코드 삽입, 파일 배포 가능)"이며, GitHub Pages는 이 요건을 만족한다.

- GitHub Pages는 `username.github.io` 형태의 기본 도메인을 제공한다. [^github-pages]
- AdSense는 사이트를 추가하고 코드/검토 절차를 거쳐야 한다. [^adsense-add-site]

# 이번에 실제로 넣은 코드 (정확한 위치)

## 1) 전역 설정: `quartz.config.ts`

아래 설정을 추가했다.

```ts
adsense: {
  enabled: false,
  publisherId: "ca-pub-XXXXXXXXXXXXXXXX",
  adsTxtEnabled: true,
  adsTxtLines: ["google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0"],
},
```

- `enabled`: `true`면 `<head>`에 AdSense 스크립트 삽입
- `publisherId`: AdSense 퍼블리셔 ID (`ca-pub-...`)
- `adsTxtEnabled`: `true`면 루트 `/ads.txt` 생성
- `adsTxtLines`: ads.txt에 쓸 실제 라인

그리고 emitter 목록에 `Plugin.AdSense()`를 추가했다.

## 2) 타입 추가: `quartz/cfg.ts`

`GlobalConfiguration`에 `adsense` 설정을 안전하게 받도록 타입을 추가했다.

- `AdSenseConfiguration` 인터페이스 신설
- `GlobalConfiguration.adsense?: AdSenseConfiguration` 추가

이렇게 하면 설정 누락/오타를 컴파일 단계에서 줄일 수 있다.

## 3) head 스크립트 + ads.txt 생성: `quartz/plugins/emitters/adsense.tsx`

새 emitter를 만들었다.

### 3-1. head 스크립트 주입

`externalResources()`에서 `additionalHead`를 통해 아래 스크립트를 주입한다.

```html
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-..." crossorigin="anonymous"></script>
```

- `enabled = false`면 삽입하지 않음
- `publisherId`가 비어 있어도 삽입하지 않음

### 3-2. 루트 `ads.txt` 생성

`emit()`에서 `/ads.txt`를 생성한다.

- 파일 경로: 최종 배포 루트의 `ads.txt`
- 내용: `adsTxtLines`를 줄바꿈으로 출력
- 비어 있으면 생성하지 않음

## 4) 플러그인 export 등록: `quartz/plugins/emitters/index.ts`

```ts
export { AdSense } from "./adsense"
```

으로 등록해 `Plugin.AdSense()`를 쓸 수 있게 했다.

# 실제 전환 방법 (승인 전 -> 승인 후)

1. 승인 전(현재 권장)
- `enabled: false` 유지
- `publisherId`, `adsTxtLines`는 실제 값으로 채움
- 배포 후 `/ads.txt` 접근 확인

2. 승인/검증 단계
- AdSense 콘솔에서 사이트 추가 [^adsense-add-site]
- 사이트 검토 상태 확인 [^adsense-review]
- 필요 시 자동 광고 코드 관련 가이드 확인 [^adsense-auto-ads]

3. 승인 후 광고 노출 시작
- `enabled: true`로 변경
- 재배포 후 페이지 소스에서 스크립트 로드 확인

# 확인 체크리스트 (배포 후)

## A. 브라우저 확인

1. `https://dreamjh1111.github.io/ads.txt` 접속 가능
2. 내용이 퍼블리셔 ID 포함 라인으로 노출되는지 확인
3. 페이지 소스(`<head>`)에 `adsbygoogle.js?client=ca-pub-...` 존재 확인

## B. AdSense 콘솔 확인

1. Sites에서 사이트 상태 확인
2. Policy Center 이슈 유무 확인
3. "검토 중/준비 중" 상태가 일정 시간 유지될 수 있음을 감안

## C. 기대치 관리

- 코드 반영 직후 바로 광고가 뜨지 않을 수 있다.
- 검토/크롤링/정책 확인에는 지연이 발생할 수 있다.

# 인수인계 (2026-03-07 기준)

아래는 "오늘 어디까지 했고, 내일 무엇을 하면 되는지"를 후임자 기준으로 정리한 기록이다.

## 1) 완료된 작업

1. AdSense 설정 구조 추가
- `quartz/cfg.ts`
  - `AdSenseConfiguration` 타입 추가
  - `GlobalConfiguration.adsense?: AdSenseConfiguration` 추가

2. 설정값 반영
- `quartz.config.ts`
  - `configuration.adsense` 추가
  - 현재 기본값:
    - `enabled: false`
    - `publisherId: "ca-pub-XXXXXXXXXXXXXXXX"` (placeholder)
    - `adsTxtEnabled: true`
    - `adsTxtLines: ["google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0"]` (placeholder)

3. AdSense emitter 구현
- `quartz/plugins/emitters/adsense.tsx` 신규 생성
  - `enabled === true`일 때만 `<head>`에 AdSense 스크립트 주입
  - `adsTxtEnabled === true`일 때 루트 `ads.txt` 생성

4. 플러그인 등록
- `quartz/plugins/emitters/index.ts`
  - `export { AdSense } from "./adsense"` 추가
- `quartz.config.ts`
  - `Plugin.AdSense()`를 emitters 배열에 추가

5. 문서 및 글 목록 반영
- 본 문서(`05-adsense-on-github-pages-domain.md`) 작성
- `content/index.md`에 05번 글 링크 추가

## 2) 아직 안 된 작업 (실수익 연결 전 필수)

1. 실제 퍼블리셔 ID 미입력
- 현재는 placeholder 값이라 실연결 상태 아님

2. 스크립트 비활성 상태
- `enabled: false` 이므로 광고 스크립트 미주입

3. AdSense 콘솔 작업 미완료
- 사이트 추가/검토/정책센터/지급 설정 미완료

4. 배포 후 실검증 미완료
- `https://dreamjh1111.github.io/ads.txt` 실경로 확인
- 페이지 소스 스크립트 존재 확인
- 콘솔 상태 확인

## 3) 내일 바로 할 일 (실행 순서)

1. `quartz.config.ts` 실값 반영
- `publisherId`를 실제 `ca-pub-...`로 변경
- `adsTxtLines`의 `pub-...`도 실제 숫자 ID로 변경

2. 배포 준비
- 승인 전에는 `enabled: false` 유지 가능
- 노출 시작 시점에 `enabled: true`로 전환

3. 빌드/배포
- 로컬 빌드 확인 후 GitHub Pages 배포

4. 배포 후 확인
- `https://dreamjh1111.github.io/ads.txt` 접근
- 페이지 소스 `<head>`에서 `adsbygoogle.js?client=ca-pub-...` 확인 (`enabled: true`일 때)

5. AdSense 콘솔 확인
- Sites 상태
- Policy Center
- Payments(지급수단/세금/임계치)

## 4) 실행 커맨드 메모

```bash
# 개발 서버
npm run dev

# 정적 빌드
npm run quartz -- build
```

## 5) 주의사항

1. `run-local.ps1`, `run-local.sh`는 삭제된 상태다. (`npm run dev` 사용)
2. 코드 반영 직후 광고 미노출은 정상일 수 있다. (검토/크롤링 지연)
3. 정책 위반 콘텐츠가 있으면 승인/노출이 지연되거나 제한될 수 있다.
4. 현 시점 `tsc --noEmit`에는 기존 코드의 미사용 import(`quartz/components/Head.tsx`의 `simplifySlug`) 경고/오류가 있어 별도 정리가 필요하다.

# 내가 참조한 공식 출처

- Google AdSense: 사이트 추가 방법 [^adsense-add-site]
- Google AdSense: 사이트 검토/상태 확인 [^adsense-review]
- Google AdSense: 자동 광고 코드/설정 [^adsense-auto-ads]
- Google AdSense: `ads.txt` 개요 [^adsense-adstxt]
- GitHub Docs: GitHub Pages 기본 도메인 개요 [^github-pages]

---

[^adsense-add-site]: Google AdSense Help, "Add your site", https://support.google.com/adsense/answer/12169212
[^adsense-review]: Google AdSense Help, "Site review in AdSense", https://support.google.com/adsense/answer/12131223
[^adsense-auto-ads]: Google AdSense Help, "Set up Auto ads", https://support.google.com/adsense/answer/9274516
[^adsense-adstxt]: Google AdSense Help, "What is ads.txt?", https://support.google.com/adsense/answer/12171612
[^github-pages]: GitHub Docs, "What is GitHub Pages?", https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages
