#!/bin/bash

# use 'tag' in uci dhcp for group client
# https://openwrt.org/docs/guide-user/base-system/dhcp_configuration#client_classifying_and_individual_options
# http://www.networksorcery.com/enp/protocol/bootp/options.htm
# https://bbs.ikuai8.com/thread-107844-1-1.html
# 
# use this for test DHCP
# sudo nmap --script broadcast-dhcp-discover
# see https://serverfault.com/questions/171744/command-line-program-to-test-dhcp-service

current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=dhcp_tag
[[ -z "$mapping_dhcp_tag" ]] && mapping_dhcp_tag=${current_path}/dhcp_tag.csv


build_file=${build_path}/${build_name}

mkdir -p ${build_path}
rm -f ${build_file}

echo "" >> ${build_file}

while IFS="," read -r tag ip_addr
do
    tag=$(echo "$tag" | tr -d '"' | tr -d '\r' )
    ip=$(echo "$ip_addr" | tr -d '"' | tr -d '\r' )
    echo "$ip - $tag"
    template=$(cat << EOF

uci delete dhcp.${tag}
uci set dhcp.${tag}="tag"
uci add_list dhcp.${tag}.dhcp_option="3,${ip}"
uci add_list dhcp.${tag}.dhcp_option="6,${ip}"
uci set dhcp.${tag}.force='1'
EOF
)
    echo "$template" >> ${build_file}
done < <(tail -n +2 ${mapping_dhcp_tag})

echo "" >> ${build_file}
echo "uci commit" >> ${build_file}
