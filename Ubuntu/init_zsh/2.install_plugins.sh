#!/bin/zsh

# Install Syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install auto-suggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

sed -i "s/plugins=(/plugins=(zsh-syntax-highlighting zsh-autosuggestions /g" ~/.zshrc
echo "Finished! reboot"
exit
