
sudo -i

echo -e '#!/bin/sh -e \ninsmod /lib/modules/tun.ko' > /usr/local/etc/rc.d/tun.sh

chmod a+x /usr/local/etc/rc.d/tun.sh

/usr/local/etc/rc.d/tun.sh

ls /dev/net/tun

mkdir /var/lib/zerotier-one

docker run -d           \
  --name zt             \
  --restart=always      \
  --device=/dev/net/tun \
  --net=host            \
  --cap-add=NET_ADMIN   \
  --cap-add=SYS_ADMIN   \
  -v /var/lib/zerotier-one:/var/lib/zerotier-one \
  zerotier/zerotier-synology:latest

docker exec -it zt zerotier-cli status

echo "Then you can use that command for join zerotier network"
echo "docker exec -it zt zerotier-cli join xxx"
echo "docker exec -it zt zerotier-cli listnetworks"