
opkg update

#dnsmasq-full
if [[ -n "$(opkg list-installed | grep 'dnsmasq ' | awk '{print $1}')" ]]; then
    opkg remove dnsmasq && opkg install dnsmasq-full
if

opkg install coreutils-nohup bash \
    curl ca-certificates ipset ip-full \
    ruby ruby-yaml kmod-tun kmod-inet-diag unzip \
    luci-compat luci luci-base

#fw3 for fw4
if [[ -n "$(command -v fw3)" ]]; then
    #iptables
    opkg install \
      iptables \
      iptables-mod-tproxy iptables-mod-extra
elif [[ -n "$(command -v fw4)" ]]; then
    #nftables
    opkg install \
      kmod-nft-tproxy 
fi

#libcap libcap-bin
if [[ -n "$(opkg list-installed | grep 'libcap-bin' | awk '{print $1}')" ]]; then
    source /etc/openwrt_release
    openwrt_snapshots="src/gz openwrt_snapshots http://downloads.openwrt.org/snapshots/packages/$DISTRIB_ARCH/base"
    echo "$openwrt_snapshots" >> /etc/opkg/customfeeds.conf
    opkg update
    opkg install libcap libcap-bin
if


# https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases" |        # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    head -n 1 |
    sed -E 's/.*"([^"]+)".*/\1/' |                                  # Pluck JSON value
    sed 's/^v//'
}
version=$(get_latest_release "vernesong/OpenClash")
curl -L ${github_url_prefix}https://github.com/vernesong/OpenClash/releases/download/v$version/luci-app-openclash_${version}_all.ipk
opkg install luci-app-openclash_${version}_all.ipk
