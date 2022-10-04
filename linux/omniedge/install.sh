#!/bin/bash

#by omniedge
[[ -z "$url" ]] && url='https://omniedge.io/install/omniedge-install.sh'

if [[ -n "$(command -v wget)" ]]; then
    wget -O - $url | sh
elif [[ -n "$(command -v curl)" ]]; then
    curl -fsSL $url | sh
fi