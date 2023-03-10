
opkg update
#fw4
if [[ -n "$(command -v fw4)" ]
then
    #nftables
    opkg install iptables-nft
fi

from_distfeeds=$(opkg list | grep tailscale)

if [ -z "$from_distfeeds" ]
then
    opkg update
    opkg install jq libustream-openssl ca-bundle kmod-tun

    # https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
    get_latest_release() {
        curl --silent "https://api.github.com/repos/$1/releases/latest" |   # Get latest release from GitHub api
            grep '"tag_name":' |                                            # Get tag line
            sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
    }
    version=$(get_latest_release "adyanth/openwrt-tailscale-enabler")

    curl -L ${github_url_prefix}https://github.com/adyanth/openwrt-tailscale-enabler/releases/download/$version/openwrt-tailscale-enabler-$version.tgz > openwrt-tailscale-enabler-$version.tgz
    tar x -zvC / -f openwrt-tailscale-enabler-$version.tgz

    /etc/init.d/tailscale start
    /etc/init.d/tailscale enable
    ls /etc/rc.d/S*tailscale*
else
    opkg install tailscale
fi

net_lan=$(ip route | grep src | grep br-lan | awk '{print $1}')
tailscale up --advertise-routes=$net_lan --advertise-exit-node

net_tailscale=$(ip addr show tailscale0 | grep "inet\b" | awk '{print $2}')

uci set network.tailscale=interface
uci set network.tailscale.proto=static
uci set network.tailscale.device=tailscale0
uci add_list network.tailscale.ipaddr=$net_tailscale
uci commit network

uci set firewall.tszone=zone
uci set firewall.tszone.input='ACCEPT'
uci set firewall.tszone.output='ACCEPT'
uci set firewall.tszone.name='tailscale'
uci set firewall.tszone.masq='1'
uci set firewall.tszone.forward='ACCEPT'
uci set firewall.tszone.network='tailscale'
uci set firewall.tszone.device='tailscale0'
uci set firewall.lanfwts=forwarding
uci set firewall.lanfwts.src='lan'
uci set firewall.lanfwts.dest='tailscale'
uci set firewall.tsfwlan=forwarding
uci set firewall.tsfwlan.src='tailscale'
uci set firewall.tsfwlan.dest='lan'
uci commit firewall
