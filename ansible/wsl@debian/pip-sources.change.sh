#!/bin/bash

if [[ -z "$(command -v pip)" ]]; then
    sudo apt install -y python3-pip
fi
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
sudo pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple