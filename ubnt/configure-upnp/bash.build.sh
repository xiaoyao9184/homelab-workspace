#!/bin/bash
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ -z "$build_path" ]] && build_path=${current_path}/build/
[[ -z "$build_name" ]] && build_name=ubnt_configure_upnp
[[ -z "$if_listen" ]] && if_listen=switch0
[[ -z "$if_wan" ]] && if_wan=eth4


build_file=${build_path}/${build_name}

mkdir -p ${build_path}
rm -f ${build_file}

template=$(cat << EOF
configure

set service upnp listen-on ${if_listen} outbound-interface ${if_wan}
commit

set service upnp2 wan ${if_wan}
set service upnp2 listen-on ${if_listen}
set service upnp2 nat-pmp enable
set service upnp2 secure-mode enable
commit

save

exit
show upnp2 rules
EOF
)
echo "$template" >> ${build_file}
