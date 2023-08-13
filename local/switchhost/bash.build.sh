#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=host
[[ -z "$mapping_csv" ]] && mapping_csv=${current_path}/host.csv
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
    echo "# local " >> ${build_file}
    echo "" >> ${build_file}
    echo "  $location -> $build_file"
done

echo "The following items will be out to script file:"
while IFS="," read -ra rows
do
    location=$(echo "${rows[$column_location]}" | tr -d '"' | tr -d '\r' )
    ip=$(echo "${rows[$column_ip]}" | tr -d '"' | tr -d '\r' )
    [[ "$column_name" ]] && name=$(echo "${rows[$column_name]}" | tr -d '"' | tr -d '\r' )
    [[ "$column_domain" ]] && domain=$(echo "${rows[$column_domain]}" | tr -d '"' | tr -d '\r' )

    if [[ "$location" && "$ip" ]]
    then
        build_file=${build_path}/${build_filename}@${location}.${build_extension}

        if [[ "$name" && "$domain" ]]
        then
            echo "  $ip - $name.$domain"
            echo "${ip} ${name}.${domain}" >> ${build_file}
        elif [[ "$name" ]]
        then
            echo "  $ip - $name.lan"
            echo "${ip} ${name}.lan" >> ${build_file}
        elif [[ "$domain" ]]
        then
            echo "  $ip - $domain"
            echo "${ip} ${domain}" >> ${build_file}
        fi
    fi
done < <(tail -n +2 ${mapping_csv})

for location in "${sorted_unique_locations[@]}"
do
    build_file=${build_path}/${build_filename}@${location}.${build_extension}
    echo "" >> ${build_file}
    echo "# End of section" >> ${build_file}
done
