#!/bin/sh

# dsm7
major_version=$(cat /etc/VERSION | grep majorversion | sed -E 's/majorversion=.(.*)./\1/')
if [[ "$major_version" -eq "7" ]]; then
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
fi

# dsm6
if [[ "$major_version" -eq "6" ]]; then
  
  # Install
  if [[ -z "$spk_url" ]]; then
    echo "miss spk_url"
    exit 1
  else 
    curl -o /tmp/zerotier.spk $spk_url
    sudo synopkg install /tmp/zerotier.spk 
    rm /tmp/zerotier.spk

    zerotier-cli status

    echo "Then you can use that command for join zerotier network"
    echo "zerotier-cli join xxx"
    echo "zerotier-cli listnetworks"
  fi
fi
