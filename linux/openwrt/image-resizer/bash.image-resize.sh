#!/usr/bin/env bash

image_path=$1
image_size=$2
if [[ -z "$image_path" ]]; then
    read -p "input image path(img.gz/.img):" image_path
fi
if [[ -z "$image_size" ]]; then
    read -p "input image size(like 512M)[512M]:" image_size
    [[ -z "$image_size" ]] && image_size='512M'
fi
image_path=$(eval realpath $image_path)
image_dir=$(dirname $image_path)
image_filename=$(basename -- "$image_path")
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

qemu-img resize -f raw ${image_path} ${image_size}
echo "resize done: $image_path"

# https://galaxysd.github.io/linux/20220618/OpenWRT-IN-ESXi

# LOOP="$(losetup -f)"
# sudo losetup -P ${LOOP} $image_path
# losetup -l
# sudo fsck.ext4 -y ${LOOP}p2
# sudo resize2fs ${LOOP}p2
# sudo losetup -d $LOOP
