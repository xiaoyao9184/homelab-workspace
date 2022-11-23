
uci del firewall.lanfwts
uci del firewall.tsfwlan
uci del firewall.tszone
uci commit firewall
uci del network.tailscale
uci commit network

tailscale down

/etc/init.d/tailscale stop
/etc/init.d/tailscale disable
ls /etc/rc.d/S*tailscale*

from_distfeeds=$(opkg list-installed | grep tailscale)

if [ -z "$from_distfeeds" ]
then
    kill $(ps | grep '[p]/etc/config/tailscaled.state' | awk '{print $1}')

    rm /etc/config/tailscaled.state
    rm /etc/init.d/tailscale
    rm /usr/bin/tailscale
    rm /usr/bin/tailscaled
    rm /tmp/tailscale.up.log
else
    opkg uninstall tailscale
fi
