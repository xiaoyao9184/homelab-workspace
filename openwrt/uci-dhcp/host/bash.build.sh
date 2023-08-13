#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=wrt_uci_dhcp_host.sh
[[ -z "$mapping_csv" ]] && mapping_csv=${current_path}/dhcp_host.csv
[[ -z "$mapping_column" ]] && mapping_column="location ip mac name tag leasetime"

build_extension="${build_name##*.}"
build_filename="${build_name%.*}"

echo "The following is the index of field in the column:"
read -a columns <<< "$mapping_column"
for index in "${!columns[@]}";
do
    [[ "${columns[$index]}" == "location" ]] && column_location=$index && echo "  ${columns[$index]} -> $index"
    [[ "${columns[$index]}" == "ip" ]] && column_ip=$index && echo "  ${columns[$index]} -> $index"
    [[ "${columns[$index]}" == "mac" ]] && column_mac=$index && echo "  ${columns[$index]} -> $index"
    [[ "${columns[$index]}" == "name" ]] && column_name=$index && echo "  ${columns[$index]} -> $index"
    [[ "${columns[$index]}" == "tag" ]] && column_tag=$index && echo "  ${columns[$index]} -> $index"
    [[ "${columns[$index]}" == "leasetime" ]] && column_leasetime=$index && echo "  ${columns[$index]} -> $index"
done

rm -rdf ${build_path}
mkdir -p ${build_path}

# no location
build_file=${build_path}/${build_filename}.${build_extension}
echo "while uci -q delete dhcp.@host[0]; do :; done" >> ${build_file}
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
    ip=$(echo "${rows[$column_ip]}" | tr -d '"' | tr -d '\r' )
    mac=$(echo "${rows[$column_mac]}" | tr -d '"' | tr -d '\r' )
    name=$(echo "${rows[$column_name]}" | tr -d '"' | tr -d '\r' )
    [[ "$column_tag" ]] && tag=$(echo "${rows[$column_tag]}" | tr -d '"' | tr -d '\r' )
    [[ "$column_leasetime" ]] && leasetime=$(echo "${rows[$column_leasetime]}" | tr -d '"' | tr -d '\r' )

    if [[ "$location" && "$ip" && "$mac" && "$name" ]]
    then
        echo "  $ip - $mac - $name"
        
        # hash=$(echo -n "$mac" | gzip -c | tail -c8 | hexdump -n4 -e '"%u"')
        
        template=$(cat << EOF
uci add dhcp host
uci set dhcp.@host[-1].mac='${mac}'
uci set dhcp.@host[-1].name='${name}'
uci set dhcp.@host[-1].dns='1'
uci set dhcp.@host[-1].ip='${ip}'
EOF
)
        build_file=${build_path}/${build_filename}@${location}.${build_extension}
        echo "$template" >> ${build_file}

        [[ "$tag" ]] && echo "uci set dhcp.@host[-1].tag='${tag}'" >> ${build_file}
        [[ "$leasetime" ]] && echo "uci set dhcp.@host[-1].leasetime='${leasetime}'" >> ${build_file}
    fi
done < <(tail -n +2 ${mapping_csv})

for location in "${sorted_unique_locations[@]}"
do
    build_file=${build_path}/${build_filename}@${location}.${build_extension}
    echo "" >> ${build_file}
    echo "uci commit" >> ${build_file}
done
