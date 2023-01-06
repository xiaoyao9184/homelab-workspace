# https://hiwbb.com/2021/10/openwrt-release-dhcp-client/

file=$(uci get dhcp.@dnsmasq[0].leasefile)
> ${file}
/etc/init.d/dnsmasq restart