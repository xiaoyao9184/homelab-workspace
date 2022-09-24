#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=ubnt_configure_static_host_mapping
[[ -z "$mapping_dhcp" ]] && mapping_dhcp=${current_path}/dhcp_host.csv
[[ -z "$mapping_domain" ]] && mapping_domain=${current_path}/domain_ip.csv


build_file=${build_path}/${build_name}

mkdir -p ${build_path}
rm -f ${build_file}

echo "configure" >> ${build_file}
echo "" >> ${build_file}

while IFS="," read -r tag leasetime ip_addr mac cl_name comment
do
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
        echo "$template" >> ${build_file}
    fi
done < <(tail -n +2 ${mapping_dhcp})

echo "" >> ${build_file}
echo "save" >> ${build_file}


declare -a wheres
while IFS="," read -r where ip_addr cl_name comment ubnt_domain
do
    where=$(echo "$where" | tr -d '"' | tr -d '\r' )
    wheres+=("$where")
done < <(tail -n +2 ${mapping_domain})
sorted_unique_wheres=($(echo "${wheres[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo "The following location script will be created: ${sorted_unique_wheres[@]}"

mkdir -p ${build_path}
for where in "${sorted_unique_wheres[@]}"
do
    build_file=${build_path}/${where}@${build_name}
    rm -f ${build_file}
    echo "configure" >> ${build_file}
    echo "" >> ${build_file}
done

while IFS="," read -r where ip_addr cl_name comment ubnt_domain
do
    where=$(echo "$where" | tr -d '"' | tr -d '\r' )
    name=$(echo "$cl_name" | tr -d '"' | tr -d '\r' )
    ip=$(echo "$ip_addr" | tr -d '"' | tr -d '\r' )
    ubnt_domain=$(echo "$ubnt_domain" | tr -d '"' | tr -d '\r')
    echo "$ip - $name - @$where"

    template=$(cat << EOF
delete system static-host-mapping host-name ${name}
set system static-host-mapping host-name ${name} inet ${ip}
commit
EOF
)
    if [[ "$name" ]]
    then
        build_file=${build_path}/${where}@${build_name}
        echo "$template" >> ${build_file}
    fi

    template=$(cat << EOF
delete system static-host-mapping host-name ${name}${ubnt_domain}
set system static-host-mapping host-name ${name}${ubnt_domain} inet ${ip}
commit
EOF
)
    if [[ "$ubnt_domain" ]]
    then
        build_file=${build_path}/${where}@${build_name}
        echo "$template" >> ${build_file}
    fi
done < <(tail -n +2 ${mapping_domain})

for where in "${sorted_unique_wheres[@]}"
do
    build_file=${build_path}/${where}@${build_name}
    echo "" >> ${build_file}
    echo "save" >> ${build_file}
done
