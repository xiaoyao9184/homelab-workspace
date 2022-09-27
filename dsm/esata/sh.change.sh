#!/bin/sh

[ -z "$portcfg_esata" ] && portcfg_esata=0x20
[ -z "$portcfg_internal" ] && portcfg_internal=0x0F


sudo cp /etc.defaults/synoinfo.conf /etc.defaults/synoinfo.conf.bak

e_cfg=$(cat /etc.defaults/synoinfo.conf | grep esataportcfg)
i_cfg=$(cat /etc.defaults/synoinfo.conf | grep internalportcfg)

sudo sed "s|$e_cfg|esataportcfg=\"$portcfg_esata\"|g" /etc.defaults/synoinfo.conf
sudo sed "s|$i_cfg|internalportcfg=\"$portcfg_internal\"|g" /etc.defaults/synoinfo.conf

sudo reboot