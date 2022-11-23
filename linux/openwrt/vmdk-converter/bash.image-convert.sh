#!/usr/bin/env bash

image_path=$1
if [[ -z "$image_path" ]]; then
    read -p "input image path(img.gz/.img):" image_path
fi
image_path=$(eval realpath $image_path)
image_dir=$(dirname $image_path)
image_filename=$(basename -- "$image_path")
image_name="${image_filename%.*}"
image_extension="${image_filename##*.}"

if [[ "$image_extension" == "gz" ]]; then
    extract_path="$image_path"
    image_path="${image_dir}/${image_filename%.*}"
    gzip -dk ${extract_path}
    echo "image extract: ${image_path}"
fi

if [[ -z "$(command -v qemu-img)" ]]; then
    sudo apt install -y qemu-utils
fi

qemu-img convert -f raw -O vmdk $image_path $image_dir/$image_name.vmdk
echo "convert done: $image_dir/$image_name.vmdk"
