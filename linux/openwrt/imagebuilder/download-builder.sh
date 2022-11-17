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


BUILDER_URL="https://downloads.openwrt.org/releases/${OPENWRT_RELEASE}/targets/${OPENWRT_TARGET/-//}/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64.tar.xz"
BUILDER_DIR=~/.openwrt/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64

if [[ ! -d ${BUILDER_DIR} ]]; then
    # mkdir -p ${BUILDER_DIR}
    # download
    echo "download ${BUILDER_URL}"
    curl -o ~/.openwrt/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64.tar.xz ${BUILDER_URL}
    xz -d ~/.openwrt/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64.tar.xz
    tar -xf ~/.openwrt/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64.tar -C ~/.openwrt
    echo "builder download ~/.openwrt/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64.tar.xz"
fi


echo "builder dir is ${BUILDER_DIR}"

cd ${BUILDER_DIR}

make info