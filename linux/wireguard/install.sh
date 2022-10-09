#!/bin/bash

#by teddysun
[[ -z "$url" ]] && url='https://raw.githubusercontent.com/teddysun/across/master/wireguard.sh'

# interactive
if [[ -n "$(command -v wget)" ]]; then
    bash <(wget -qO- $url)
elif [[ -n "$(command -v curl)" ]]; then
    bash <(curl -L $url)
fi
