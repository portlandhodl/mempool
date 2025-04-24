#!/usr/bin/env zsh
#######################
##### OS packages #####
#######################

# packages needed for mempool ecosystem
DEBIAN_PKG=()
DEBIAN_PKG+=(zsh vim curl screen openssl python3 dialog cron)
DEBIAN_PKG+=(build-essential git clang cmake jq)
DEBIAN_PKG+=(autotools-dev autoconf automake pkg-config bsdmainutils)
DEBIAN_PKG+=(libevent-dev libdb-dev libssl-dev libtool autotools-dev)
DEBIAN_PKG+=(libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev)
DEBIAN_PKG+=(nodejs npm mariadb-server nginx-core python3-certbot-nginx rsync ufw)
DEBIAN_PKG+=(geoipupdate)

DEBIAN_UNFURL_PKG=()
DEBIAN_UNFURL_PKG+=(cups chromium-bsu libatk1.0 libatk-bridge2.0 libxkbcommon-dev libxcomposite-dev)
DEBIAN_UNFURL_PKG+=(libxdamage-dev libxrandr-dev libgbm-dev libpango1.0-dev libasound-dev)

# packages needed for mempool ecosystem
FREEBSD_PKG=()
FREEBSD_PKG+=(zsh sudo git screen curl wget calc neovim cmake)
FREEBSD_PKG+=(openssh-portable py311-pip rust llvm17 jq base64 libzmq4)
FREEBSD_PKG+=(boost-libs autoconf automake gmake gcc13 libevent libtool pkgconf)
FREEBSD_PKG+=(nginx rsync py311-certbot-nginx mariadb1011-server)
FREEBSD_PKG+=(redis sqlite3 libzmq4)
FREEBSD_PKG+=(libepoll-shim)

FREEBSD_UNFURL_PKG=()
FREEBSD_UNFURL_PKG+=(nvidia-driver-470 chromium xinit xterm twm ja-sourcehansans-otf)
FREEBSD_UNFURL_PKG+=(zh-sourcehansans-sc-otf ko-aleefonts-ttf lohit tlwg-ttf)
