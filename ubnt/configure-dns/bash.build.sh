#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=ubnt_configure_dns_forwarding
[[ -z "$mapping_domain" ]] && mapping_domain=${current_path}/domain_ip.csv


declare -a wheres
while IFS="," read -r where ip_addr cl_name comment ubnt_domain
do
    where=$(echo "$where" | tr -d '"' | tr -d '\r' )
    wheres+=("$where")
done < <(tail -n +2 ${mapping_domain})
sorted_unique_wheres=($(echo "${wheres[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo "The following location script will be created: ${sorted_unique_wheres[@]}"

mkdir -p ${build_path}
for where in "${sorted_unique_wheres[@]}"
do
    build_file=${build_path}/${where}@${build_name}
    rm -f ${build_file}
    echo "configure" >> ${build_file}
    echo "" >> ${build_file}
done

while IFS="," read -r where ip_addr cl_name comment ubnt_domain
do
    where=$(echo "$where" | tr -d '"' | tr -d '\r' )
    ip=$(echo "$ip_addr" | tr -d '"' | tr -d '\r' )
    name=$(echo "$cl_name" | tr -d '"' | tr -d '\r' )
    ubnt_domain=$(echo "$ubnt_domain" | tr -d '"' | tr -d '\r')
    echo "$ip - $name - @$where"

    template=$(cat << EOF
set service dns forwarding options address=/.${name}/${ip}
commit
EOF
)
    if [[ "$name" ]]
    then
        build_file=${build_path}/${where}@${build_name}
        echo "$template" >> ${build_file}
    fi

    template=$(cat << EOF
set service dns forwarding options address=/.${name}${ubnt_domain}/${ip}
commit
EOF
)
    if [[ "$ubnt_domain" ]]
    then
        build_file=${build_path}/${where}@${build_name}
        echo "$template" >> ${build_file}
    fi
done < <(tail -n +2 ${mapping_domain})

for where in "${sorted_unique_wheres[@]}"
do
    build_file=${build_path}/${where}@${build_name}
    echo "" >> ${build_file}
    echo "save" >> ${build_file}
done
