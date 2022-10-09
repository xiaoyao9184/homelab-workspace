#!/bin/bash

#by XTLS
[[ -z "$url" ]] && url='https://github.com/XTLS/Xray-install/raw/main/install-release.sh'

# interactive
if [[ -n "$(command -v wget)" ]]; then
    bash <(wget -qO- $url) @ install
elif [[ -n "$(command -v curl)" ]]; then
    bash <(curl -L $url) @ install
fi
