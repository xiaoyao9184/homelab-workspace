#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=shared_mount.sh
[[ -z "$path_list" ]] && path_list=/volume1


build_file=${build_path}/${build_name}

mkdir -p ${build_path}
rm -f ${build_file}

echo "#!/bin/sh -e" >> ${build_file}
echo "" >> ${build_file}

path_list=( $path_list )
for path in "${path_list[@]}"
do
    echo "$path"
    template=$(cat << EOF
sudo mount --make-shared $path
EOF
)
    echo "$template" >> ${build_file}
done

echo "" >> ${build_file}
