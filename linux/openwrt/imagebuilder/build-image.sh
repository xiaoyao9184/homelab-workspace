#!/usr/bin/env bash

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
    BUILDER_DIR=~/.openwrt/openwrt-imagebuilder-${OPENWRT_TARGET}.Linux-x86_64
else
    BUILDER_DIR=~/.openwrt/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64
fi
echo "builder dir is ${BUILDER_DIR}"

if [[ -d "${config_dir}/config" ]]; then
	BUILDER_FILE="FILES=${config_dir}/config"
else
	BUILDER_FILE=""
fi

BUILDER_PACKAGES=${BUILDER_PACKAGES//  / }
BUILDER_PACKAGES=${BUILDER_PACKAGES/$'\n'/}

cd ${BUILDER_DIR}

make image PROFILE=$BUILDER_PROFILE PACKAGES="$BUILDER_PACKAGES" $BUILDER_FILE