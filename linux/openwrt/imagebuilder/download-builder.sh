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
    BUILDER_URL="https://downloads.openwrt.org/snapshots/targets/${OPENWRT_TARGET/-//}/openwrt-imagebuilder-${OPENWRT_TARGET}.Linux-x86_64.tar.xz"
    BUILDER_DIR=~/.openwrt/openwrt-imagebuilder-${OPENWRT_TARGET}.Linux-x86_64
else
    BUILDER_URL="https://downloads.openwrt.org/releases/${OPENWRT_RELEASE}/targets/${OPENWRT_TARGET/-//}/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64.tar.xz"
    BUILDER_DIR=~/.openwrt/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64
fi
echo "builder dir is ${BUILDER_DIR}"

if [[ ! -d ${BUILDER_DIR} ]]; then
    # mkdir -p ${BUILDER_DIR}
    # download
    echo "download ${BUILDER_URL}"
    curl -o ${BUILDER_DIR}.tar.xz ${BUILDER_URL}
    xz -d ${BUILDER_DIR}.tar.xz
    tar -xf ${BUILDER_DIR}.tar -C ~/.openwrt
    echo "builder download ${BUILDER_DIR}.tar.xz"
fi

cd ${BUILDER_DIR}

make info