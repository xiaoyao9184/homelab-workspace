
# This is the list of packages you need to have available on your system that will run Hass.io if you are using Debian/Ubuntu:
sudo apt-get install apparmor-utils apt-transport-https avahi-daemon ca-certificates curl
dbus jq network-manager socat software-properties-common

#To perform the Hass.io installation, run the following command as root:
$ curl -sL https://raw.githubusercontent.com/home-assistant/hassio-build/master/install/hassio_install | bash -s