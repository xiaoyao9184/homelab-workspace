#!/bin/bash

#by docker
[[ -z "$url" ]] && url='https://get.docker.com'

if [[ -n "$(command -v wget)" ]]; then
    wget -O - $url | bash
elif [[ -n "$(command -v curl)" ]]; then
    curl -fsSL $url | bash
fi