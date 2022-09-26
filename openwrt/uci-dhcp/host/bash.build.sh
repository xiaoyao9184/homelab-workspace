#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=dhcp_host
[[ -z "$mapping_dhcp_host" ]] && mapping_dhcp_host=${current_path}/dhcp_host.csv


build_file=${build_path}/${build_name}

mkdir -p ${build_path}
rm -f ${build_file}

echo "while uci -q delete dhcp.@host[0]; do :; done" >> ${build_file}
echo "" >> ${build_file}

while IFS="," read -r tag leasetime ip_addr mac cl_name comment
do
    tag=$(echo "$tag" | tr -d '"' | tr -d '\r' )
    leasetime=$(echo "$leasetime" | tr -d '"' | tr -d '\r' )
    ip=$(echo "$ip_addr" | tr -d '"' | tr -d '\r' )
    mac=$(echo "$mac" | tr -d '"' | tr -d '\r' )
    name=$(echo "$comment" | tr -d '"' | tr -d '\r' )
    hash=$(echo -n "$mac" | gzip -c | tail -c8 | hexdump -n4 -e '"%u"')
    if [[ -z "$name" ]]
    then
        name=$(echo "$cl_name" | tr -d '"' | tr -d '\r' )
    fi
    echo "$ip - $mac - $name"
    template=$(cat << EOF
uci add dhcp host # =cfg${hash}
uci set dhcp.@host[-1].mac='${mac}'
uci set dhcp.@host[-1].name='${name}'
uci set dhcp.@host[-1].dns='1'
uci set dhcp.@host[-1].ip='${ip}'
uci set dhcp.@host[-1].leasetime='${leasetime}'
uci set dhcp.@host[-1].tag='${tag}'
EOF
)
    echo "$template" >> ${build_file}
done < <(tail -n +2 ${mapping_dhcp_host})

echo "" >> ${build_file}
echo "uci commit" >> ${build_file}
