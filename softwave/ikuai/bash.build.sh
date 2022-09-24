#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/hosts/
[[ -z "$build_name" ]] && build_name=${build_path}/host
[[ -z "$mapping_dhcp" ]] && mapping_dhcp=${current_path}/dhcp_host.csv


build_file=${build_path}/${build_name}

mkdir -p ${build_path}
rm -f ${build_file}

echo "enabled,interface,ip_addr,mac,cl_name,comment" >> ${build_file}

while IFS="," read -r tag leasetime ip_addr mac cl_name comment
do
    comment=$(echo "$comment" | tr -d '"' | tr -d '\r' )
    name=$(echo "$cl_name" | tr -d '"' | tr -d '\r' )
    mac=$(echo "$mac" | tr -d '"' | tr -d '\r' )
    ip=$(echo "$ip_addr" | tr -d '"' | tr -d '\r' )
    echo "$ip - $name - $mac - $comment"

    template=$(cat << EOF
"yes","auto","${ip}","${mac}","${name}","${comment}"
EOF
)
    echo "$template" >> ${build_file}
done < <(tail -n +2 ${mapping_dhcp})

echo "" >> ${build_file}
