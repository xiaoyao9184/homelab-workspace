source /etc/openwrt_release

if [[ "$DISTRIB_RELEASE" != "SNAPSHOT" ]]
then
    echo "only support SNAPSHOT release: $DISTRIB_RELEASE"
    exit 1
fi
curl --output kernel.ipk -L https://downloads.openwrt.org/snapshots/targets/x86/64/packages/kernel_5.15.80-1-53ea5a0694b1d3faa99c939dd703b18d_x86_64.ipk
opkg install kernel.ipk
