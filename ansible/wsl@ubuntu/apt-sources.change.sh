#!/bin/bash

sudo sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
cat /etc/apt/sources.list
sudo apt update