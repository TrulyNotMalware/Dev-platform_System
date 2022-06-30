#!/bin/bash


# Install zsh
sudo apt install zsh -y

# Change bash to zsh
chsh -s /usr/bin/zsh

echo "Continue to login again!, if you set default then, type 0."
exit
