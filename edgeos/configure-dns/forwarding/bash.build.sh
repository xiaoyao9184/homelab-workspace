#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=edgeos_configure_dns_forwarding.sh
[[ -z "$mapping_csv" ]] && mapping_csv=${current_path}/dns.csv
[[ -z "$mapping_column" ]] && mapping_column="location ip name domain"

build_extension="${build_name##*.}"
build_filename="${build_name%.*}"

echo "The following is the index of field in the column:"
read -a columns <<< "$mapping_column"
for index in "${!columns[@]}";
do
    [[ "${columns[$index]}" == "location" ]] && column_location=$index && echo "  ${columns[$index]} -> $index"
    [[ "${columns[$index]}" == "ip" ]] && column_ip=$index && echo "  ${columns[$index]} -> $index"
    [[ "${columns[$index]}" == "name" ]] && column_name=$index && echo "  ${columns[$index]} -> $index"
    [[ "${columns[$index]}" == "domain" ]] && column_domain=$index && echo "  ${columns[$index]} -> $index"
done

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
    echo "configure" >> ${build_file}
    echo "" >> ${build_file}
    echo "  $location -> $build_file"
done

echo "The following items will be out to script file:"
while IFS="," read -ra rows
do
    location=$(echo "${rows[$column_location]}" | tr -d '"' | tr -d '\r' )
    ip=$(echo "${rows[$column_ip]}" | tr -d '"' | tr -d '\r' )
    name=$(echo "${rows[$column_name]}" | tr -d '"' | tr -d '\r' )
    domain=$(echo "${rows[$column_domain]}" | tr -d '"' | tr -d '\r' )

    if [[ "$location" && "$domain" && "$ip" == "::" ]]
    then
        echo "  $ip - $domain"

        template=$(cat << EOF
set service dns forwarding options server=/${domain}/#
set service dns forwarding options address=/${domain}/::
commit
EOF
)
        build_file=${build_path}/${build_filename}@${location}.${build_extension}
        echo "$template" >> ${build_file}
    elif [[ "$location" && "$ip" && "$name" && "$domain" == "lan" ]]
    then
        echo "  $ip - $name/$name.$domain"

        template=$(cat << EOF
set service dns forwarding options address=/${name}.lan/${ip}
set service dns forwarding options address=/${name}/${ip}
commit
EOF
)
        build_file=${build_path}/${build_filename}@${location}.${build_extension}
        echo "$template" >> ${build_file}
    elif [[ "$location" && "$domain" ]]
    then
        echo "  $ip - $domain"

        template=$(cat << EOF
set service dns forwarding options address=/${domain}/${ip}
commit
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
    echo "save" >> ${build_file}
done