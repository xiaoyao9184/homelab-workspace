#!/bin/bash

#by zerotier
[[ -z "$url" ]] && url='https://install.zerotier.com'

# interactive
if [[ -n "$(command -v wget)" ]]; then
    bash <(wget -qO- $url)
elif [[ -n "$(command -v curl)" ]]; then
    bash <(curl -L $url)
fi
