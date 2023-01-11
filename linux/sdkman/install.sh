#!/bin/bash

sudo apt install unzip zip curl

#by sdkman
[[ -z "$url" ]] && url='https://get.sdkman.io'

if [[ -n "$(command -v wget)" ]]; then
    wget -O - $url | bash
elif [[ -n "$(command -v curl)" ]]; then
    curl -fsSL $url | bash
fi