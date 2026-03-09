---
title: 04. 홈서버 구축기 (Proxmox)
description: Ubuntu VM 생성 및 커스터마이징 과정을 정리한 글
socialDescription: Proxmox 기반 Ubuntu VM 구축과 데스크톱/개발 환경 커스터마이징 기록
date: "2026-03-07T00:00:04+09:00"
draft: false
tags:
  - home-server
  - proxmox
  - vm
  - ubuntu
  - ko-kr
---
![[Pasted image 20260307163101.png]]
## Linux(Ubuntu) VM 생성
### 생성은 [홈서버 구축기 (Proxmox) 3](https://velog.io/@dreamjh/%ED%99%88%EC%84%9C%EB%B2%84-%EA%B5%AC%EC%B6%95%EA%B8%B0-Proxmox-3) 를 참조
우분투의 경우도 윈도우 VM과 동일한 과정으로 진행된다.

1.  [우분투 이미지 공식 다운로드 사이트](https://ubuntu.com/download/desktop) 에서 ISO파일을 다운 받는다
	- 여기서 서버와 데스크탑버전이 존재하는데 데스크탑버전을 추천한다. 내가 생각하는 우분투를 사용하는 이유는 다음과 같다.
	1. 수많은 데비안계열 리눅스 중 하나일뿐이다. 그런데 익숙하고 편리한 UX/UI를 제공해준다 (다른 커스텀 OS도 존재하지만 이만큼의 안정성과 업데이트, 디자인을 제공하는데는 기본 우분투가 좋다고 생각한다.)
    2. 수많은 강력한 어플리케이션 지원 및 보안기능을 제공한다.
    - 그런데 여기서 우분투 서버를 선택한다? > 필자는 CLI가 GUI환경보다 익숙하다 할만큼 경험이 있다. 하지만 여전히 설정을 열고 마우스로 환경설정을 하는게 편하다. CLI명령어가 어려워서? 이건 어렵고 말고의 문제가 아니다. GUI환경은 OS를 설치하고 초기 환경설정(대표적으로 키보드, 네트워크, 한국어설정 등)을 하는데는 여전히 압도적인 파워를 낼 수 있다.
    - GUI환경이 더 리소스를 많이 먹지 않는가? > 우분투를 사용해봤다면 알수 있는 사실이지만 GUI환경으로 설치해도 옵션을 변경하면 부팅시 CLI모드로 사용이 가능하다. 즉, 설정을 완료한 이후 CLI로 바꿔버리면 그만이다.
2. Proxmox에 ISO를 올린다.
3. VM을 실행한다. [홈서버 구축기 (Proxmox) 3](https://velog.io/@dreamjh/%ED%99%88%EC%84%9C%EB%B2%84-%EA%B5%AC%EC%B6%95%EA%B8%B0-Proxmox-3)

과정자체는 쉽기때문에 (부족한 부분은 구글링을 통해 해결하자) 다음으로 넘어간다.

## Ubuntu 커스텀(선택)
![[Pasted image 20260307163122.png]]
(완성된 모습)

필자는 우분투를 주력 OS로 사용할만큼 좋아한다. 따라서 GUI환경을 사용하기 편하게 커스텀해보자.

해당 커스텀은 외국의 한 유저의 커스텀을 참조하였다.
시작하기 전에 다음 요구 사항을 충족하는지 확인하세요.

### 요구 사항
- GNOME 버전 : GNOME 46
- Linux 배포판 : Ubuntu 24.04

### 초기 설정
- 기존 패키지 업데이트 및 패키지 종속성 설치
```
sudo apt update && sudo apt dist-upgrade -y

sudo apt install curl \
rsync \
git \
gdebi \
nautilus-admin \
nautilus-extension-gnome-terminal \
sassc \
gnome-tweaks \
gnome-shell-extension-manager -y

```

### 앱 및 종속성 설치
[필수 파일 다운로드 링크](https://www.pling.com/p/2176652/)

위 링크에서 아래 항목들을 Downloads디렉토리에 다운받는다.
- fishomp-config.zip
- cava-config.zip
- conky-config.zip
- cursors-theme.zip
- fonts.zip
- gnome-extensions.zip
- GTK-Themes.zip
- icon-themes.zip
- ubuntu-desktop-settings.zip
- wallpapers.zip

### GNOME Extensions 설치
```
unzip -o $HOME/Downloads/gnome-extensions.zip -d $HOME/.local/share/gnome-shell/
```

### GTK 테마 설치
1. .themes 디렉토리를 홈 디렉토리에 생성
```
mkdir -p $HOME/.themes
```
2. Orchis GTK테마 추가
```
unzip -o $HOME/Downloads/GTK-Themes.zip -d $HOME/.themes
```
3. 취향에 따라서 Dark 테마와 White 테마중 하나를 골라 링크를 생성해준다. (링크가 아니라 파일을 옮겨도 무방)
```
# 다크테마
ln -sf $HOME/.themes/Orchis-Dark/gtk-4.0/{assets,gtk.css,gtk-dark.css} $HOME/.config/gtk-4.0/
# 화이트테마
ln -sf $HOME/.themes/Orchis-Light/gtk-4.0/{assets,gtk.css,gtk-dark.css} $HOME/.config/gtk-4.0/
```

### 아이콘 테마 설치
1. 홈 디렉토리에 .local/share/icons 디렉토리 추가
```
mkdir -p $HOME/.local/share/icons
```
2. 아이콘 테마 추가
```
unzip -o $HOME/Downloads/icon-themes.zip -d $HOME/.local/share/icons

```

### Cursors 테마 설치
1. 홈 디렉토리에 .icon 디렉토리 추가
```
mkdir -p $HOME/.icons
```
2. cursor 테마 추가
```
unzip -o $HOME/Downloads/cursors-theme.zip -d $HOME/.icons

```

### 폰트 및 배경화면 설치
1. 폰트 설치
```
unzip -o $HOME/Downloads/fonts.zip -d $HOME/.local/share/

```
2. 배경화면 설치
```
sudo unzip -o ~/Downloads/wallpapers.zip -d /usr/share/backgrounds/

```

### (선택사항) Conky 위젯 설치[날씨 위젯]
1. Ubuntu/Debian 운영체제 필수 패키지 설치
```
sudo apt install conky-all jq curl playerctl -y

```
2. conky config 설치
```
unzip -o ~/Downloads/conky-config.zip -d $HOME/.config

```
3. 도시 및 날씨 정보 변경

```
sudo vim ~/.config/conky/Alfirk-MOD/scripts/weather.sh
```

```
# Variables
# get your city id at https://openweathermap.org/find and replace
city_id=1733046

# you can use this or replace with yours
api_key=60d7b980f7da638967fed7f0aaf80f84
```
이제 https://openweathermap.org/find 로 가서 도시 ID를 얻고, 도시를 입력한다. API 키를 얻고 싶다면 가입 후 브라우저의 주소창에서 도시를 클릭하고, 도시 ID를 city_id파일 섹션에 복사한다.

### (선택사항) Cava 위젯 설치[오디오 출력 스펙트럼 위젯]
1. Ubuntu/Debian 운영체제 필수 패키지 설치
```
sudo apt install cava -y
```
2. Cava config 설치
```
unzip -o $HOME/Downloads/cava-config.zip -d $HOME/.config/
```

### Neofetch 설치
neofetch는 OS는 아래 사진처럼 운영체제 및 PC정보를 한눈에 볼 수 있도록 해주는 툴이다.

![[Pasted image 20260307165531.png]]

1. neofetch 설치
```
sudo apt install neofetch -y
```

2. neofetch config 설치
```
unzip -o $HOME/Downloads/neofetch-config.zip -d $HOME/.config/
```

### Fish Shell & Oh My Posh
이부분은 개인적으로 필수라고 생각한다. 우분투의 기본 쉘인 bash Shell을 더욱 편하게 사용할 수 있도록 Fish Shell로 바꿔주는 부분이다. 가장 대표적인 기능으로는 이전 명령어들을 분석해서 명령어의 일부를 쳤을때 자동완성기능, 쉘을 더 편하게 사용할 수 있는 여러 특수기능들을 제공한다.

1. Fish Shell 설치
```
sudo apt install fish -y
```
2. Fish Shell을 Default Shell로 변경
```
chsh -s /usr/bin/fish
```
3. Oh My Posh 설치
```
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
```
4. oh-my-posh 파일 권한 설정
```
sudo chmod +x /usr/local/bin/oh-my-posh
```

### Fish Shell 설치 및 Oh My Posh 설정
```
unzip -o $HOME/Downloads/fishomp-config.zip -d $HOME
chmod u+rw ~/.poshthemes/*.json
```

### Flatpak 및 AppImages 지원 활성화
```
sudo apt install gnome-software gnome-software-plugin-flatpak flatpak libfuse2 -y
flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo
```

### Flatpak 앱 설치
1. 명령어를 통해 flatpak 어플리케이션 몇가지를 설치한다.
```
flatpak install flathub io.bassi.Amberol -y
flatpak install flathub net.agalwood.Motrix -y
flatpak install flathub com.rafaelmardojai.Blanket -y
flatpak install flathub com.github.KRTirtho.Spotube -y
flatpak install flathub com.mattjakeman.ExtensionManager -y
```

2. flatpak에 대한 Orichis GTK 테마 지원 활성화
```
sudo flatpak override --filesystem=$HOME/.themes
sudo flatpak override --filesystem=$HOME/.local/share/icons
sudo flatpak override --filesystem=xdg-config/gtk-4.0
```

### GNOME 앱 설치
```
sudo apt install gnome-weather \
gnome-maps \
gnome-audio \
gnome-calendar \
gnome-clocks \
gnome-connections \
gnome-console \
gnome-contacts \
gnome-music \
vlc \
gnome-shell-pomodoro -y
```

### (선택)Plymouth 테마 설치
이건 그냥 부팅되는 동안 그래픽 애니메이션을 변경하는 작업이므로 선택사항이다.
하면 이쁘긴 하다.
```
sudo apt install plymouth -y
```

```
sudo unzip -o $HOME/Downloads/plymouth-theme.zip -d /usr/share/plymouth/themes

sudo update-alternatives --install \
  /usr/share/plymouth/themes/default.plymouth default.plymouth \
  /usr/share/plymouth/themes/hexagon_dots/hexagon_dots.plymouth 100

sudo update-alternatives --config default.plymouth
```

출력:
```
There are 2 choices for the alternative default.plymouth (providing /usr/share/plymouth/themes/default.plymouth).

  Selection    Path                                                         Priority   Status
------------------------------------------------------------
* 0            /usr/share/plymouth/themes/mint-logo/mint-logo.plymouth       200       auto mode
  1            /usr/share/plymouth/themes/bgrt/bgrt.plymouth                 110       manual mode
  2            /usr/share/plymouth/themes/hexagon_dots/hexagon_dots.plymouth               100       

Press <enter> to keep the current choice[*], or type selection number: 2
update-alternatives: using /usr/share/plymouth/themes/hexagon_dots/hexagon_dots.plymouth to provide /usr/share/plymouth/themes/default.plymouth (default.plymouth) in manual mode
```
```
sudo update-initramfs -u
```

### GNOME 구성 적용
```
unzip $HOME/Downloads/ubuntu-desktop-settings.zip -d $HOME/Downloads/

dconf load / < $HOME/Downloads/ubuntu-desktop-settings.conf
```

설치완료

## 🌟 결론 및 향후 계획
Proxmox를 설치하고 윈도우, 우분투를 설치 완료했고 게시글로 정리하지는 않았지만 nas역시 설치를 완료했다.

proxmox에 https 설정을 적용하는 작업, 포트포워딩 정리, VM템플릿 적용 등 많은 설정을 진행하였는데 디테일한 작업 환경 설정은 사용자마다, 상황마다 다르기 때문에 올리지 않기로 결정하였다.

여기서 최종적으로 홈서버 구축은 여기서 마무리하고 다음 글에서는 홈서버를 활용한 여러가지 서비스를 구동하는 과정을 다를 예정이다.
