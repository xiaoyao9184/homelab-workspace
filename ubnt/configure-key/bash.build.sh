#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=ubnt_configure_login_ssh_key.sh
[[ -z "$user_name" ]] && user_name=ubnt
[[ -z "$key_path" ]] && key_path=$HOME/.ssh/id_rsa.pub

if [[ -z "$key" ]]; then
    if [[ ! -f "$key_path" ]]; then
        echo "$key_path not exists. set env 'key_path' for specify the public key path"
        exit 1
    fi
    key=$(cat $key_path | awk '{ print $2 }')
fi


build_file=${build_path}/${build_name}

mkdir -p ${build_path}
rm -f ${build_file}

echo "configure" >> ${build_file}
echo "" >> ${build_file}

echo "$user_name - $key"

template=$(cat << EOF
set system login user $user_name authentication public-keys me type ssh-rsa
set system login user $user_name authentication public-keys me key $key
commit
EOF
)
echo "$template" >> ${build_file}

echo "" >> ${build_file}
echo "save" >> ${build_file}
