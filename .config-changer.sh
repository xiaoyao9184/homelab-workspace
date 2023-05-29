#!/bin/bash

url_now="$(git config --get submodule..config.url)"
if [[ -z "$url_now" ]]; then
    echo "Cant find '.config' submodule"
    echo "Make sure the command has results: 'git config --get submodule..config.url'"
    exit 1
fi

pattern="homelab-config\.git$"
if [[ "$url_now" =~ $pattern ]]; then
    user_name="$(git config --get user.name)"
    letter="${user_name:0:1}"

    project_name_now="homelab-config.git"
    project_name_change="homelab-config-4${letter}.git"
    url_default="${url_now/${project_name_now}/${project_name_change}}"
else
    project_name_now=$(echo "$url_now" | sed 's#.*/##')
    project_name_change="homelab-config.git"
    url_default="${url_now/${project_name_now}/${project_name_change}}"
fi
read -p "Enter your '.config' submodule url [$url_default]: " url
url_change=${url:-$url_default}

git submodule deinit -f .config
rm -rf .git/modules/.config/
git config submodule..config.url ${url_change}
git submodule update --recursive --remote
