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
[[ -z "$build_name" ]] && build_name=dhcp_tag.sh
[[ -z "$mapping_dhcp_tag" ]] && mapping_dhcp_tag=${current_path}/dhcp_tag.csv

build_extension="${build_name##*.}"
build_filename="${build_name%.*}"

rm -rdf ${build_path}
mkdir -p ${build_path}

# no location
build_file=${build_path}/${build_filename}.${build_extension}
echo "" >> ${build_file}

# read all location
declare -a locations
while IFS="," read -r location tag ip_addr
do
    location=$(echo "$location" | tr -d '"' | tr -d '\r' )
    locations+=("$location")
done < <(tail -n +2 ${mapping_dhcp_tag})
sorted_unique_locations=($(echo "${locations[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo "The following location script will be created: ${sorted_unique_locations[@]}"

# output by location
for location in "${sorted_unique_locations[@]}"
do
    build_file=${build_path}/${build_filename}@${location}.${build_extension}
    echo "" >> ${build_file}
done

while IFS="," read -r location tag ip_addr
do
    location=$(echo "$location" | tr -d '"' | tr -d '\r' )
    tag=$(echo "$tag" | tr -d '"' | tr -d '\r' )
    ip=$(echo "$ip_addr" | tr -d '"' | tr -d '\r' )

    template=$(cat << EOF

uci delete dhcp.${tag}
uci set dhcp.${tag}="tag"
uci add_list dhcp.${tag}.dhcp_option="3,${ip}"
uci add_list dhcp.${tag}.dhcp_option="6,${ip}"
uci set dhcp.${tag}.force='1'
EOF
)
    if [[ "$tag" ]]
    then
        echo "$ip - $tag"
        build_file=${build_path}/${build_filename}@${location}.${build_extension}
        echo "$template" >> ${build_file}
    fi
done < <(tail -n +2 ${mapping_dhcp_tag})

for location in "${sorted_unique_locations[@]}"
do
    build_file=${build_path}/${build_filename}@${location}.${build_extension}
    echo "" >> ${build_file}
    echo "uci commit" >> ${build_file}
done
