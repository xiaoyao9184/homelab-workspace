
mirror_host=$1
if [ -z "$mirror_host" ]
then
    read -p "input mirror host[mirrors.cloud.tencent.com]:" mirror_host
    if [ -z "$mirror_host" ]
    then
        mirror_host='mirrors.cloud.tencent.com'
    if
fi

cat /etc/opkg/distfeeds.conf

sed -i.bak "s|//downloads.openwrt.org|//$mirror_host/openwrt|g" /etc/opkg/distfeeds.conf

opkg update
