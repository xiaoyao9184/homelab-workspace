#!/bin/bash

curl https://rclone.org/install.sh | sudo bash

rclone config


config_path=$(rclone config file | grep /)
config_dir="$( cd "$( dirname "${config_path}" )" >/dev/null 2>&1 && pwd )"
config_list=$(rclone config show | grep '\[' | sed -E 's/\[(.*)\]/\1/')
config_count=$(echo "$config_list" | wc -l)

if (( $config_count > 1 )); then
  array=( $(config_list) )
  select config_name in array
  do
    read -p "Input mount target path of $config_name: " config_mount
  done
else
  config_name="$config_list"
fi

[[ -z "$config_mount" ]] && config_mount=$HOME/$config_name
mkdir -p ${config_mount}


script=$(cat << EOF
#!/bin/sh -e
rclone \
 mount ${config_name}: /var/services/homes/$USER/${config_name} \
 --config=$config_path \
 --allow-other \
 --allow-non-empty \
 --buffer-size 32M \
 --vfs-read-chunk-size=32M \
 --vfs-read-chunk-size-limit 2048M \
 --vfs-cache-mode writes \
 --dir-cache-time 96h \
 --daemon
EOF
)
echo "$script" >> ${config_dir}/${config_name}.sh
echo "You have script ${config_dir}/${config_name}.sh"

cp ${config_dir}/${config_name}.sh /usr/local/etc/rc.d/rclone.sh
chmod a+x /usr/local/etc/rc.d/rclone.sh
bash /usr/local/etc/rc.d/rclone.sh
echo "Run script /usr/local/etc/rc.d/rclone.sh"
