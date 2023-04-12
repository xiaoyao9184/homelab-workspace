# https://openwrt.org/docs/guide-user/installation/openwrt_x86#resizing_ext4_rootfs
# https://oriolrius.cat/2022/08/04/resize-squasfs-ext4-partition-of-openwrt-in-a-raspberry-pi/

opkg update
opkg install lsblk losetup resize2fs

LOOP="$(losetup -f)"
BOOT="$(sed -n -e "\|\s/boot\s.*$|{s///p;q}" /etc/mtab)"
if [ -z "$BOOT" ]
then
    ROOT="/dev/$(lsblk -n -i -r -o NAME,MOUNTPOINT,FSTYPE | grep 'ext4' | grep '/' | awk '{print $1}')"

    echo "no boot partition in /etc/mtab!!! but root partition maybe: $ROOT"
    read -p "do you want to proceed? (yes/no) " yn
    case $yn in
        yes | y )
            ;;
        no | n )
            echo "exiting..."
            exit
            ;;
        * )
            echo "invalid response"
            exit 1
            ;;
    esac

    losetup ${LOOP} ${ROOT}
    fsck.ext4 -y ${LOOP}
else
    DISK="${BOOT%%[0-9]*}"
    PART="$((${BOOT##*[^0-9]}+1))"
    ROOT="${DISK}${PART}"

    SQUASHFS_ROM="$(lsblk -n -i -r -o NAME,MOUNTPOINT,FSTYPE | grep 'squashfs' | grep '/rom' | awk '{print $1}')"

    if [ -z "$SQUASHFS_ROM" ]
    then
        losetup ${LOOP} ${ROOT}
    else
        # loop_off="$(losetup | grep $SQUASHFS_ROM | awk '{print $3}')"
        # losetup -o ${loop_off} ${LOOP} ${ROOT}
        LOOP="$(losetup -n -l | sed -n -e "\|\s.*\s${ROOT#/dev}\s.*$|{s///p;q}")"
    fi
fi

resize2fs ${LOOP}
reboot
