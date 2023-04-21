#!/bin/bash

if [[ -z "$(command -v wslpath)" ]] || [[ -z "$(command -v wslvar)" ]]; then
    sudo apt install -y gnupg2 apt-transport-https wget
    wget -O - https://pkg.wslutiliti.es/public.key | sudo tee -a /etc/apt/trusted.gpg.d/wslu.asc

    debian_code=$(env -i bash -c '. /etc/os-release ; echo $VERSION_CODENAME')
    echo "deb https://pkg.wslutiliti.es/debian $debian_code main" | sudo tee -a /etc/apt/sources.list

    sudo apt update
    sudo apt install -y wslu
fi

user_path=$(wslpath "$(wslvar USERPROFILE)")
user_name=$(whoami)

sudo umount /mnt/c
sudo mount -t drvfs 'C:\' /mnt/c -o metadata


if [[ -d $HOME/.ssh ]]
then
    real_path=$(cd -P "$HOME/.ssh" && pwd)

    if [[ "$real_path" == "$user_path/.ssh" ]]
    then
        echo "already link $HOME/.ssh to $real_path"
        linked="true"
    else
        backup_path="$HOME/.ssh.bak.$(date +%s)"
        echo "backup $HOME/.ssh move to $backup_path"
        mv "$HOME/.ssh" "$backup_path"
    fi
fi
if [[ -z "$linked" ]]
then
    echo "make link $HOME/.ssh to $user_path/.ssh"
    sudo ln -s $user_path/.ssh $HOME/.ssh
fi

sudo chown -R $user_name:$user_name $user_path/.ssh
sudo chmod -R 700 $user_path/.ssh/
ls -la $HOME/.ssh/