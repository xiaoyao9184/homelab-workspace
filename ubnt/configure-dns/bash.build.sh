#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=ubnt_configure_dns_forwarding.sh
[[ -z "$mapping_domain" ]] && mapping_domain=${current_path}/domain_ip.csv

build_extension="${build_name##*.}"
build_filename="${build_name%.*}"

rm -rdf ${build_path}
mkdir -p ${build_path}

# no location 
build_file=${build_path}/${build_filename}.${build_extension}
cat <<EOT >> ${build_file}
configure
delete service dns forwarding options
commit
save
EOT

# read all where
declare -a wheres
while IFS="," read -r where ip_addr cl_name comment ubnt_domain
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

while IFS="," read -r where ip_addr cl_name comment ubnt_domain
do
    where=$(echo "$where" | tr -d '"' | tr -d '\r' )
    ip=$(echo "$ip_addr" | tr -d '"' | tr -d '\r' )
    name=$(echo "$cl_name" | tr -d '"' | tr -d '\r' )
    ubnt_domain=$(echo "$ubnt_domain" | tr -d '"' | tr -d '\r')
    echo "$ip - $name - @$where"

    template=$(cat << EOF
set service dns forwarding options address=/.${name}/${ip}
commit
EOF
)
    if [[ "$name" ]]
    then
        build_file=${build_path}/${build_filename}@${where}.${build_extension}
        echo "$template" >> ${build_file}
    fi

    template=$(cat << EOF
set service dns forwarding options address=/.${name}${ubnt_domain}/${ip}
commit
EOF
)
    if [[ "$ubnt_domain" ]]
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
