#!/usr/bin/env bash
# set -x

_usage() {
	echo "Could not find config file."
	echo "Usage: $0 [/path/to/openwrt.conf]"
	exit 1
}

config_path=$1
config_dir=$(cd $(dirname $config_path) && pwd )
default_config_file=$config_dir/openwrt.conf
config_file=${1:-$default_config_file}
source $config_file 2>/dev/null || { _usage; exit 1; }

if [[ "${OPENWRT_RELEASE}" == "snapshots" ]]; then
    builder_url="https://downloads.openwrt.org/snapshots/targets/${OPENWRT_TARGET/-//}/openwrt-imagebuilder-${OPENWRT_TARGET}.Linux-x86_64.tar.xz"
    builder_dir=~/.openwrt/openwrt-imagebuilder-${OPENWRT_TARGET}.Linux-x86_64
else
    builder_url="https://downloads.openwrt.org/releases/${OPENWRT_RELEASE}/targets/${OPENWRT_TARGET/-//}/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64.tar.xz"
    builder_dir=~/.openwrt/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64
fi
echo "builder dir is ${builder_dir}"

if [[ ! -d ${builder_dir} ]]; then
    # download
    echo "download ${builder_url}"
    curl -o ${builder_dir}.tar.xz ${builder_url}
    xz -dk ${builder_dir}.tar.xz
    tar -xf ${builder_dir}.tar -C ~/.openwrt
    echo "builder download ${builder_dir}.tar.xz"
fi

cd ${builder_dir}
make info