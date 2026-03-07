---
title: 03. 홈서버 구축기 (Proxmox)
description: Proxmox에서 Windows 11 VM 생성과 테스트 경험을 정리한 글
socialDescription: Proxmox 환경에서 Windows 11 가상머신을 생성하고 사용한 과정을 기록
date: 2026-03-07
draft: false
tags:
  - home-server
  - proxmox
  - vm
  - windows11
  - ko-kr
---
![[Pasted image 20260307162722.png]]
## 🧩 Proxmox VM 생성
### 필요한 VM 확인하기
내가 필요한 VM은 다음과 같다.

1. 현재 정기 구독중인 클라우드 서버를 대체할 수 있는 NAS
2. 공인인증서, 오피스 등 윈도우가 필요한 상황에서 사용 가능한 윈도우PC
3. 개발용 리눅스 서버 다수(aws의 ec2대용)

우선 VM에 리소스를 분배해보면
- Nas : 4GB RAM 1.0TB ssd
- 윈도우 : 6GB RAM 100GB ssd
- ubuntu(여러개의 VM으로 쪼개어 쓸 예정) : 남는 RAM과 ssd를 유동적으로 사용

위와 같이 설계하였다.
윈도우의 경우 패러럴즈만큼의 성능만 나와준다면 사용상 문제는 없을것이라 램을 6GB로 설정했지만 테스트 후 미세조정이 필요할 것 같다.

## ✅ Windows 11 VM 설치
Proxmox에 VM을 올리는건 매우 간단했다.

[윈도우 11 공식 다운로드 링크](https://www.microsoft.com/ko-kr/software-download/windows11)
위 링크에서 윈도우 11 ISO 이미지를 받은 후 Proxmox에 웹으로 접속하여 이미지 파일을 등록해주면 해당 이미지로 VM을 생성할 수 있게 된다.

![[Pasted image 20260307162759.png]]
우선 위 링크에 접속하여 윈도우 ISO를 받아준다. 여기서 Proxmox의 강점이 나오는데 초반 설치를 제외하고는 추가적인 USB 저장매체나 서버에 직접 모니터, 키보드 마우스를 물리고 접속할 필요가 없다.

[홈서버 구축기 (Proxmox) 2](https://velog.io/@dreamjh/%ED%99%88%EC%84%9C%EB%B2%84-%EA%B5%AC%EC%B6%95%EA%B8%B0-Proxmox-2)

여기서 마지막에 해주었던 도메인으로 접속하면 
![[Pasted image 20260307162807.png]]
이렇게 Proxmox서버의 모든 리소스를 관리및 감독 가능한 콘솔이 뜨게 되며
![[Pasted image 20260307162816.png]]
![[Pasted image 20260307162826.png]]
위에서 다운받은 Windows.iso파일을 업로드하면 준비는 끝이다.
![[Pasted image 20260307162836.png]]
여기서 Successfully가 떠야 성공이다 (인터넷 요금제를 100mb로 사용중인데 업로드중 인터넷 대역폭? 문제로 업로드 실패가 있었으니 꼭 확인해보자)

![[Pasted image 20260307162845.png]]

![[Pasted image 20260307162854.png]]

![[Pasted image 20260307162903.png]]

![[Pasted image 20260307162910.png]]

![[Pasted image 20260307162917.png]]

![[Pasted image 20260307162926.png]]

![](https://velog.velcdn.com/images/dreamjh/post/488591e4-ce15-4dac-bb16-bb374605b5d3/image.png)

여기까지 설정했다면 거의 다왔다.

![[Pasted image 20260307162939.png]]

이렇게 해당 VM이 생성되면 Start Now를 누르면 끝!!


![[Pasted image 20260307162946.png]]

윈도우 설정해주면서 마무리 하면 원격 윈도우 머신을 얻을 수 있게 된다.


---
### 1달 사용 후기
결과적으로 윈도우 11 VM을 삭제하기로 결정했다.
가장 큰 이유는 윈도우 원격용 N100 미니피씨를 하나 더 구매하였기 때문......
결국 가상화니 뭐니해도 네이티브 구동이 가장 좋기 때문에 현재는 윈도우 네이티브 서버를 하나 따로 구축해서 사용중이다.

1달간 Proxmox에 윈도우를 사용해본 경험을 말해보면...
[만족스러운 반쪽 윈도우]
정도일 것 같다. 내가 원하던 공인인증서, 윈도우 전용 프로그램 구동? 문제 없었다. 그런데 그 이상의 작업( 개발이라던지 개발이라던지..) 하는 작업에 활용하기에는 너무도 불편했다.
특히나 그래픽카드를 가상으로 돌리는 과정에서 안그래도 부족한 내장그래픽의 성능을 활용하지 못하기 때문에 유튜브 영상조차 재생하는순간 cpu 100%찍으며 이륙소리를 내는 pc를 보고.....

하지만 정말 급할때 사용할 윈도우서버가 필요하다면, 혹은 자신의 pc성능이 충분하다면 추천해볼만 한 작업인것 같다.

