#!/usr/bin/env zsh
#######################
##### OS packages #####
#######################

# packages needed for mempool ecosystem on FreeBSD
PKG=()
PKG+=(zsh sudo git screen curl wget calc neovim cmake gcc)
PKG+=(openssh-portable py311-pip rust llvm17 jq base64 libzmq4)
PKG+=(boost-libs autoconf automake gmake gcc13 libevent libtool pkgconf)
PKG+=(nginx rsync py311-certbot-nginx mariadb1011-server)
PKG+=(redis sqlite3 libzmq4)
PKG+=(libepoll-shim)

# packages needed for Unfurl on FreeBSD
UNFURL_PKG=()
UNFURL_PKG+=(nvidia-driver-470 chromium xinit xterm twm ja-sourcehansans-otf)
UNFURL_PKG+=(zh-sourcehansans-sc-otf ko-aleefonts-ttf lohit tlwg-ttf)
