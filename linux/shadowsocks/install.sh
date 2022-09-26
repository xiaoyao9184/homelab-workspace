#!/bin/bash

#by GitHub
[[ -z "$url" ]] && url='https://raw.githubusercontent.com/teddysun/shadowsocks_install/master'

if [[ -n "$(command -v wget)" ]]; then
    wget -O shadowsocks-all.sh $url/shadowsocks-all.sh
elif [[ -n "$(command -v curl)" ]]; then
    curl -O $url/shadowsocks-all.sh
fi

chmod +x shadowsocks-all.sh

./shadowsocks-all.sh 2>&1 | tee shadowsocks-all.log