#!/bin/bash

#by tailscale
[[ -z "$url" ]] && url='https://tailscale.com'

if [[ -n "$(command -v wget)" ]]; then
    wget -O - $url/install.sh | sh
elif [[ -n "$(command -v curl)" ]]; then
    curl -fsSL $url/install.sh | sh
fi