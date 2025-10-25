#!/bin/bash

# Run the following line to setup MCreator Link Service on your Pi:
# curl -sL http://mcreator.net/linkpi | sudo bash

# WARNING!!! THIS SCRIPT REQUIRES INTERNET CONNECTION!!

echo ====================================================
echo Updating system
echo ====================================================

# install dependencies
sudo apt-get -y update && 
sudo apt-get -y dist-upgrade && 
sudo apt-get -y install openjdk-17-jdk pigpio

echo ====================================================
echo Installing Pi4j
echo ====================================================

# install pi4j v2
curl -sSL https://pi4j.com/install | sudo bash

echo ====================================================
echo Downloading MCreator Link
echo ====================================================

# we make install dir
sudo mkdir /opt/mcreatorlink

# download MCreator Link
sudo wget -O /opt/mcreatorlink/mcreator_link_pi.jar https://github.com/Pylo/MCreatorLinkRaspberryPi/releases/download/1.3/mcreator_link_1.3_pi.jar

echo ====================================================
echo Installing MCreator Link service
echo ====================================================

# create service file
sudo su -c 'sudo cat >/etc/systemd/system/mcreatorlink.service <<EOL
[Unit]
Description=MCreator Link
After=network.target
 
[Service]
Type=simple
WorkingDirectory=/opt/mcreatorlink
ExecStart=/bin/bash -c "sudo java -cp '.:mcreator_link_pi.jar:/opt/pi4j/lib/*' --add-opens java.base/java.nio=ALL-UNNAMED net.mcreator.minecraft.link.raspberrypi.Service"
Restart=always
User=root
 
[Install]
WantedBy=multi-user.target
EOL'

# activate the service
sudo chmod 644 /etc/systemd/system/mcreatorlink.service
sudo systemctl daemon-reload
sudo systemctl enable mcreatorlink.service
sudo systemctl start mcreatorlink.service

# wait for the service to start

sleep 5

# check the status
sudo systemctl status mcreatorlink.service

echo ====================================================
echo MCreator Link was installed. Service is now running
echo and will be running by default in the startup.
echo
echo To check the service status, use this command:
echo
echo sudo systemctl status mcreatorlink.service
echo
echo ====================================================
