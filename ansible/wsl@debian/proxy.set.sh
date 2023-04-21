#!/bin/bash

ip=`cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }'`
export http_proxy="$ip:17890"
export https_proxy="$ip:17890"