#!/bin/bash

sudo sed -i "s@http://.*.debian.org@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
cat /etc/apt/sources.list
sudo apt update