#!/bin/bash

if [[ -z "$(command -v wslpath)" ]]; then
    sudo apt update
    sudo apt install -y wslu
fi

user_path=$(wslpath "$(wslvar USERPROFILE)")
user_name=$(whoami)

sudo cp -r $user_path/.ssh $HOME
sudo chown -R $user_name:$user_name $HOME/.ssh/
sudo chmod -R 700 $HOME/.ssh/
ls -la $HOME/.ssh/