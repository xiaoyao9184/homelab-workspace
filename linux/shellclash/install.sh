#!/bin/bash

#by GitHub
[[ -z "$url" ]] && url='https://raw.githubusercontent.com/juewuy/ShellClash/master'

if [[ -n "$(command -v wget)" ]]; then
    wget -q --no-check-certificate -O /tmp/install.sh $url/install.sh  && sh /tmp/install.sh && source /etc/profile &> /dev/null
elif [[ -n "$(command -v curl)" ]]; then
    sh -c "$(curl -kfsSl $url/install.sh)" && source /etc/profile &> /dev/null
fi