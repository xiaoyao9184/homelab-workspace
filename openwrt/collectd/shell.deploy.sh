
opkg update
opkg install luci-app-statistics \
 collectd \
 collectd-mod-cpu \
 collectd-mod-interface \
 collectd-mod-iwinfo \
 collectd-mod-load \
 collectd-mod-memory \
 collectd-mod-network \
 collectd-mod-uptime

export INFLUXDB_ADDRESS=influxdb
uci batch <<EOF
set luci_statistics.collectd_network.enable='1'
set luci_statistics.collectd_network.Forward='0'
set luci_statistics.influxdb=collectd_network_server
set luci_statistics.influxdb.port='25826'
set luci_statistics.influxdb.host="${INFLUXDB_ADDRESS}"
EOF
uci commit

/etc/init.d/luci_statistics enable
/etc/init.d/collectd enable
/etc/init.d/luci_statistics restart
/etc/init.d/collectd restart