#get file
wget https://raw.githubusercontent.com/syncthing/syncthing/master/etc/linux-systemd/system/syncthing@.service

#move file to service
sudo mv syncthing@.service /etc/systemd/system/syncthing@$USER.service

#enable service
sudo systemctl enable syncthing@$USER.service
sudo systemctl start syncthing@$USER.service