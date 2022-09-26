#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=ubnt_configure_dhcp_static_mapping.sh
[[ -z "$mapping_dhcp" ]] && mapping_dhcp=${current_path}/dhcp_host.csv
[[ -z "$subnet" ]] && subnet=192.168.1.0/24


build_file=${build_path}/${build_name}

mkdir -p ${build_path}
rm -f ${build_file}

echo "configure" >> ${build_file}
echo "" >> ${build_file}

while IFS="," read -r tag leasetime ip_addr mac cl_name comment
do
    name=$(echo "$cl_name" | tr -d '"' | tr -d '\r' )
    mac=$(echo "$mac" | tr -d '"' | tr -d '\r' )
    ip=$(echo "$ip_addr" | tr -d '"' | tr -d '\r' )
    echo "$ip - $mac - $name"

    template=$(cat << EOF
set service dhcp-server shared-network-name LAN subnet $subnet static-mapping ${name}
set service dhcp-server shared-network-name LAN subnet $subnet static-mapping ${name} ip-address ${ip}
set service dhcp-server shared-network-name LAN subnet $subnet static-mapping ${name} mac-address ${mac}
commit
EOF
)
    if [[ "$name" ]]
    then
        echo "$template" >> ${build_file}
    fi
done < <(tail -n +2 ${mapping_dhcp})

echo "" >> ${build_file}
echo "save" >> ${build_file}
