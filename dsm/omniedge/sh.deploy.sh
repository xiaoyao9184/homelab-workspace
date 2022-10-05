#!/bin/sh

# Install
if [[ -z "$spk_url" ]]; then
  echo "miss spk_url"
  exit 1
else 
  curl -o /tmp/omniedge.spk $spk_url
  sudo synopkg install /tmp/omniedge.spk 
  rm /tmp/omniedge.spk
fi

# dsm7
major_version=$(cat /etc/VERSION | grep majorversion | sed -E 's/majorversion=.(.*)./\1/')
if [[ "$major_version" -eq "7" ]]; then
  sudo sed -i 's/package/root/g' /var/packages/omniedge/conf/privilege
fi

if [[ -z "$NETWORK_ID" ]]; then
  read -p 'NETWORK_ID: ' NETWORK_ID
fi
if [[ -z "$SECURITY_KEY" ]]; then
  read -p 'SECURITY_KEY: ' SECURITY_KEY
fi
if [[ -z "$IP_RANGE" ]]; then
  read -p 'IP_RANGE: ' IP_RANGE
fi
sudo sed -i "s@NETWORK_ID=.*@NETWORK_ID=$NETWORK_ID@g" /var/packages/omniedge/target/var/dialog
sudo sed -i "s@SECURITY_KEY=.*@SECURITY_KEY=$SECURITY_KEY@g" /var/packages/omniedge/target/var/dialog
sudo sed -i "s@IP_RANGE=.*@IP_RANGE=$IP_RANGE@g" /var/packages/omniedge/target/var/dialog

sudo synopkg start omniedge
echo "Then you can use omniedge"
