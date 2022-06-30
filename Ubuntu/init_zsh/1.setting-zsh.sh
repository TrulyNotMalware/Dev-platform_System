#!/bin/zsh

# Install fonts.
sudo apt install fonts-powerline

# Install Oh-my-zsh
sudo sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Change Theme to agnoster
THEME_NAME="agnoster"
sed -i "s/robbyrussell/agnoster/g" ~/.zshrc

echo "Finished! Reload please."
exit
