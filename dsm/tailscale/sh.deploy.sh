#!/bin/sh

# Install
if [[ -z "$spk_url" ]]; then
  sudo synopkg install_from_server Tailscale
else 
  curl -o /tmp/tailscale.spk $spk_url
  sudo synopkg install /tmp/tailscale.spk 
  rm /tmp/tailscale.spk
fi

# https://tailscale.com/kb/1131/synology/#installation-steps
# Add CAP_NET_ADMIN
sudo setcap cap_net_admin+eip /var/packages/Tailscale/target/bin/tailscaled

# https://blog.icedream.xyz/2020/07/05/%E8%A7%A3%E5%86%B3%E7%BE%A4%E6%99%96%E5%AE%89%E8%A3%85zerotier%E6%88%96openvpn%E6%97%B6%E6%89%BE%E4%B8%8D%E5%88%B0-tun-%E8%AE%BE%E5%A4%87%E7%9A%84%E9%97%AE%E9%A2%98/
# Create the necessary file structure for /dev/net/tun
if ( [ ! -c /dev/net/tun ] ); then
  if ( [ ! -d /dev/net ] ); then
    sudo mkdir -m 755 /dev/net
  fi
  sudo mknod /dev/net/tun c 10 200
  sudo chmod 0666 /dev/net/tun
fi
# Load the tun module if not already loaded
if ( !(lsmod | grep -q "^tun\s") ); then
  sudo insmod /lib/modules/tun.ko
fi

# Add sysvinit startup script
echo -e '#!/bin/sh -e \n/var/packages/Tailscale/target/bin/tailscale configure-host' > /usr/local/etc/rc.d/tailscale.sh
chmod a+x /usr/local/etc/rc.d/tailscale.sh
/usr/local/etc/rc.d/tailscale.sh
ls /dev/net/tun

# Up
sudo synopkg start Tailscale
sudo tailscale up --advertise-exit-node
echo "Then you can use tailscale command"
