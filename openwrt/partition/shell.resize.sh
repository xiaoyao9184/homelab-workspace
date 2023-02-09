# https://openwrt.org/docs/guide-user/installation/openwrt_x86#resizing_partitions

opkg update
opkg install parted lsblk

BOOT="$(sed -n -e "\|\s/boot\s.*$|{s///p;q}" /etc/mtab)"

if [ -z "$BOOT" ]
then
    ROOT_NAME="$(lsblk -n -i -r -o NAME,MOUNTPOINT,FSTYPE | grep 'ext4' | grep '/' | awk '{print $1}')"
    DISK="/dev/$(lsblk -no pkname /dev/${ROOT_NAME})"
    PART="$(cat /proc/partitions | grep ${ROOT_NAME} | tail -1 | awk '{print $2}')"
else
    DISK="${BOOT%%[0-9]*}"
    PART="$((${BOOT##*[^0-9]}+1))"
fi

echo Fix | parted -l
parted ${DISK} resizepart ${PART} 100%

TABLE="$(parted -l | grep '^Partition Table' | awk '{split($0,t,": ");print t[2]}')"
if [ "$TABLE"=="gpt" ]
then
    lsblk -n -o NAME,MOUNTPOINT,PARTUUID

    ROOT="${DISK}${PART}"
    UUID="$(lsblk -n -o PARTUUID ${ROOT})"
    sed -i -r -e "s|(PARTUUID=)\S+|\1${UUID}|g" /boot/grub/grub.cfg
fi

reboot
