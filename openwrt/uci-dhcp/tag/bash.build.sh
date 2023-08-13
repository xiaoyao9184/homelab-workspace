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
[[ -z "$mapping_csv" ]] && mapping_csv=${current_path}/dhcp_tag.csv
[[ -z "$mapping_column" ]] && mapping_column="location tag ip"

build_extension="${build_name##*.}"
build_filename="${build_name%.*}"

echo "The following is the index of field in the column:"
read -a columns <<< "$mapping_column"
for index in "${!columns[@]}";
do
    [[ "${columns[$index]}" == "location" ]] && column_location=$index && echo "  ${columns[$index]} -> $index"
    [[ "${columns[$index]}" == "tag" ]] && column_tag=$index && echo "  ${columns[$index]} -> $index"
    [[ "${columns[$index]}" == "ip" ]] && column_ip=$index && echo "  ${columns[$index]} -> $index"
done

rm -rdf ${build_path}
mkdir -p ${build_path}

# no location
build_file=${build_path}/${build_filename}.${build_extension}
echo "" >> ${build_file}

echo "The following location script will be created:"
# read all location
declare -a locations
while IFS="," read -ra rows
do
    location=$(echo "${rows[$column_location]}" | tr -d '"' | tr -d '\r' )
    locations+=("$location")
done < <(tail -n +2 ${mapping_csv})
sorted_unique_locations=($(echo "${locations[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# output by location
for location in "${sorted_unique_locations[@]}"
do
    build_file=${build_path}/${build_filename}@${location}.${build_extension}
    echo "" >> ${build_file}
    echo "  $location -> $build_file"
done

echo "The following items will be out to script file:"
while IFS="," read -ra rows
do
    location=$(echo "${rows[$column_location]}" | tr -d '"' | tr -d '\r' )
    tag=$(echo "${rows[$column_tag]}" | tr -d '"' | tr -d '\r' )
    ip=$(echo "${rows[$column_ip]}" | tr -d '"' | tr -d '\r' )

    if [[ "$location" && "$tag" && "$ip" ]]
    then
        echo "  $tag - $ip"

        template=$(cat << EOF

uci delete dhcp.${tag}
uci set dhcp.${tag}="tag"
uci add_list dhcp.${tag}.dhcp_option="3,${ip}"
uci add_list dhcp.${tag}.dhcp_option="6,${ip}"
uci set dhcp.${tag}.force='1'
EOF
)
        build_file=${build_path}/${build_filename}@${location}.${build_extension}
        echo "$template" >> ${build_file}
    fi
done < <(tail -n +2 ${mapping_csv})

for location in "${sorted_unique_locations[@]}"
do
    build_file=${build_path}/${build_filename}@${location}.${build_extension}
    echo "" >> ${build_file}
    echo "uci commit" >> ${build_file}
done
