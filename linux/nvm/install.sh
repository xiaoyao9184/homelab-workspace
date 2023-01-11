#!/bin/bash

#by github
[[ -z "$url" ]] && url='https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh'

if [[ -n "$(command -v wget)" ]]; then
    wget -O - $url | bash
elif [[ -n "$(command -v curl)" ]]; then
    curl -fsSL $url | bash
fi