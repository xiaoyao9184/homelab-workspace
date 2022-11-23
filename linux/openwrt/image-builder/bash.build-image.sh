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
    builder_dir=~/.openwrt/openwrt-imagebuilder-${OPENWRT_TARGET}.Linux-x86_64
else
    builder_dir=~/.openwrt/openwrt-imagebuilder-${OPENWRT_RELEASE}-${OPENWRT_TARGET}.Linux-x86_64
fi
echo "builder dir is ${builder_dir}"

BUILDER_PACKAGES=${BUILDER_PACKAGES//  / }
BUILDER_PACKAGES=${BUILDER_PACKAGES/$'\n'/}
builder_cmd="make image PROFILE=$BUILDER_PROFILE PACKAGES='$BUILDER_PACKAGES'"
if [[ -n "$BUILDER_FILE" ]]; then
	builder_cmd="${builder_cmd} FILES=${config_dir}${BUILDER_FILE}"
fi
if [[ -n "$BUILDER_CONFIG_TARGET_KERNEL_PARTSIZE" ]]; then
	builder_cmd="${builder_cmd} CONFIG_TARGET_KERNEL_PARTSIZE=${BUILDER_CONFIG_TARGET_KERNEL_PARTSIZE}"
fi
if [[ -n "$BUILDER_CONFIG_TARGET_ROOTFS_PARTSIZE" ]]; then
	builder_cmd="${builder_cmd} CONFIG_TARGET_ROOTFS_PARTSIZE=${BUILDER_CONFIG_TARGET_ROOTFS_PARTSIZE}"
fi

cd ${builder_dir}
eval $builder_cmd

if [[ -n "${BUILDER_NAME}" ]]; then
    mv $builder_dir/build_dir/target-x86_64_musl/linux-x86_64/tmp $builder_dir@$BUILDER_NAME
	echo "builder result is $builder_dir@$BUILDER_NAME/"
fi
