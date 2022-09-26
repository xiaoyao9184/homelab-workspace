#!/bin/bash

#by tailscale
[[ -z "$url" ]] && url='https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master'

# interactive
if [[ -n "$(command -v wget)" ]]; then
    bash <(wget -qO- $url/install-release.sh)
elif [[ -n "$(command -v curl)" ]]; then
    bash <(curl -L $url/install-release.sh)
fi
