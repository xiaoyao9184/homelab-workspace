#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/hosts/
[[ -z "$build_name" ]] && build_name=ikuai_dhcp_static.csv
[[ -z "$mapping_dhcp" ]] && mapping_dhcp=${current_path}/dhcp_host.csv

build_extension="${build_name##*.}"
build_filename="${build_name%.*}"

rm -rdf ${build_path}
mkdir -p ${build_path}

# read all location
declare -a locations
while IFS="," read -r location tag leasetime ip_addr mac cl_name comment
do
    location=$(echo "$location" | tr -d '"' | tr -d '\r' )
    locations+=("$location")
done < <(tail -n +2 ${mapping_dhcp})
sorted_unique_locations=($(echo "${locations[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo "The following location script will be created: ${sorted_unique_locations[@]}"

# output by location
for location in "${sorted_unique_locations[@]}"
do
    build_file=${build_path}/${build_filename}@${location}.${build_extension}
    echo "enabled,interface,ip_addr,mac,cl_name,comment" >> ${build_file}
done

while IFS="," read -r location tag leasetime ip_addr mac cl_name comment
do
    location=$(echo "$location" | tr -d '"' | tr -d '\r' )
    comment=$(echo "$comment" | tr -d '"' | tr -d '\r' )
    name=$(echo "$cl_name" | tr -d '"' | tr -d '\r' )
    mac=$(echo "$mac" | tr -d '"' | tr -d '\r' )
    ip=$(echo "$ip_addr" | tr -d '"' | tr -d '\r' )
    echo "$ip - $name - $mac - $comment"

    template=$(cat << EOF
"yes","auto","${ip}","${mac}","${name}","${comment}"
EOF
)
    if [[ "$name" ]]
    then
        build_file=${build_path}/${build_filename}@${location}.${build_extension}
        echo "$template" >> ${build_file}
    fi
done < <(tail -n +2 ${mapping_dhcp})

for location in "${sorted_unique_locations[@]}"
do
    build_file=${build_path}/${build_filename}@${location}.${build_extension}
    echo "" >> ${build_file}
done
