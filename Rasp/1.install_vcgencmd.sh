#!/bin/zsh

#USER_NAME=`whoami`
users=`who | awk '{print $1}'`

# Install pip3
sudo apt-get install python3-pip3

# Install libs
sudo usermod -aG video ${users}
sudo apt install libraspberrypi-bin

echo "Reboot."
sudo reboot
