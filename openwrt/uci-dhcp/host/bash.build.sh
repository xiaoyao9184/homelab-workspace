#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=dhcp_host.sh
[[ -z "$mapping_dhcp_host" ]] && mapping_dhcp_host=${current_path}/dhcp_host.csv

build_extension="${build_name##*.}"
build_filename="${build_name%.*}"

rm -rdf ${build_path}
mkdir -p ${build_path}

# no location
build_file=${build_path}/${build_filename}.${build_extension}
echo "while uci -q delete dhcp.@host[0]; do :; done" >> ${build_file}
echo "" >> ${build_file}

# read all location
declare -a locations
while IFS="," read -r location tag leasetime ip_addr mac cl_name comment
do
    location=$(echo "$location" | tr -d '"' | tr -d '\r' )
    locations+=("$location")
done < <(tail -n +2 ${mapping_dhcp_host})
sorted_unique_locations=($(echo "${locations[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo "The following location script will be created: ${sorted_unique_locations[@]}"

# output by location
for location in "${sorted_unique_locations[@]}"
do
    build_file=${build_path}/${build_filename}@${location}.${build_extension}
    echo "" >> ${build_file}
done

while IFS="," read -r location tag leasetime ip_addr mac cl_name comment
do
    location=$(echo "$location" | tr -d '"' | tr -d '\r' )
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
    if [[ "$name" ]]
    then
        echo "$ip - $mac - $name"
        build_file=${build_path}/${build_filename}@${location}.${build_extension}
        echo "$template" >> ${build_file}
    fi
done < <(tail -n +2 ${mapping_dhcp_host})

for location in "${sorted_unique_locations[@]}"
do
    build_file=${build_path}/${build_filename}@${location}.${build_extension}
    echo "" >> ${build_file}
    echo "uci commit" >> ${build_file}
done
