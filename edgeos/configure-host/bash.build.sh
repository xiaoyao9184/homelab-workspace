#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=edgeos_configure_static_host_mapping.sh
[[ -z "$mapping_dhcp" ]] && mapping_dhcp=${current_path}/dhcp_host.csv
[[ -z "$mapping_domain" ]] && mapping_domain=${current_path}/domain_ip.csv

build_extension="${build_name##*.}"
build_filename="${build_name%.*}"

rm -rdf ${build_path}
mkdir -p ${build_path}

# no location
build_file=${build_path}/${build_filename}.${build_extension}
cat <<EOT >> ${build_file}
configure
delete system static-host-mapping host-name
commit
save
EOT

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
    echo "configure" >> ${build_file}
    echo "" >> ${build_file}
done

while IFS="," read -r location tag leasetime ip_addr mac cl_name comment
do
    location=$(echo "$location" | tr -d '"' | tr -d '\r' )
    name=$(echo "$cl_name" | tr -d '"' | tr -d '\r' )
    ip=$(echo "$ip_addr" | tr -d '"' | tr -d '\r' )
    echo "$ip - $name"

    template=$(cat << EOF
delete system static-host-mapping host-name ${name}.lan
set system static-host-mapping host-name ${name}.lan inet ${ip}
commit
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
    echo "save" >> ${build_file}
done


# read all where
declare -a wheres
while IFS="," read -r where ip_addr cl_name comment edgeos_domain
do
    where=$(echo "$where" | tr -d '"' | tr -d '\r' )
    wheres+=("$where")
done < <(tail -n +2 ${mapping_domain})
sorted_unique_wheres=($(echo "${wheres[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo "The following location script will be created: ${sorted_unique_wheres[@]}"

# output by where
for where in "${sorted_unique_wheres[@]}"
do
    build_file=${build_path}/${build_filename}@${where}.${build_extension}
    rm -f ${build_file}
    echo "configure" >> ${build_file}
    echo "" >> ${build_file}
done

while IFS="," read -r where ip_addr cl_name comment edgeos_domain
do
    where=$(echo "$where" | tr -d '"' | tr -d '\r' )
    name=$(echo "$cl_name" | tr -d '"' | tr -d '\r' )
    ip=$(echo "$ip_addr" | tr -d '"' | tr -d '\r' )
    edgeos_domain=$(echo "$edgeos_domain" | tr -d '"' | tr -d '\r')
    echo "$ip - $name - @$where"

    template=$(cat << EOF
delete system static-host-mapping host-name ${name}
set system static-host-mapping host-name ${name} inet ${ip}
commit
EOF
)
    if [[ "$name" ]]
    then
        build_file=${build_path}/${build_filename}@${where}.${build_extension}
        echo "$template" >> ${build_file}
    fi

    template=$(cat << EOF
delete system static-host-mapping host-name ${name}${edgeos_domain}
set system static-host-mapping host-name ${name}${edgeos_domain} inet ${ip}
commit
EOF
)
    if [[ "$edgeos_domain" ]]
    then
        build_file=${build_path}/${build_filename}@${where}.${build_extension}
        echo "$template" >> ${build_file}
    fi
done < <(tail -n +2 ${mapping_domain})

for where in "${sorted_unique_wheres[@]}"
do
    build_file=${build_path}/${build_filename}@${where}.${build_extension}
    echo "" >> ${build_file}
    echo "save" >> ${build_file}
done