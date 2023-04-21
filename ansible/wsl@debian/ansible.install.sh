#!/bin/bash

sudo update-ca-certificates --fresh
sudo apt install -y python3-pip
pip3 install --upgrade pip
pip3 install ansible

source ~/.profile
ansible --version