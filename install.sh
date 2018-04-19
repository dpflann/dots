#!/bin/bash

date_comment="# (Install Date: $(date))\n";

# install bash
echo -e "Personalizing bash...";
echo -e "\n# BEGIN" >> ~/.bash_profile;
echo -e "$date_comment" >> ~/.bash_profile
cat bash_profile/.bash_profile >> ~/.bash_profile
echo -e "\n# END" >> ~/.bash_profile
source ~/.bash_profile
green "Success!";

# install vim 
echo -e "Personalizing vim...";
mkdir -p ~/.vim/colors
mkdir -p ~/.vim/syntax
mkdir -p ~/.vim/ftdetect
cp vim/colors/* ~/.vim/colors 
cp vim/syntax/* ~/.vim/syntax 
cp vim/ftdetect/* ~/.vim/ftdetect 

echo -e "\n\" BEGIN" >> ~/.vimrc;
echo -e "\" $date_comment" >> ~/.vimrc
cat vim/.vimrc >> ~/.vimrc
echo -e "\n\" END" >> ~/.vimrc
green "Success!";

# install tmux
echo -e "Personalizing tmux...";
echo -e "\n# BEGIN" >> ~/.tmux.conf;
echo -e "$date_comment" >> ~/.tmux.conf
cat tmux/.tmux.conf >> ~/.tmux.conf
echo -e "\n# END" >> ~/.tmux.conf
green "Success!";

# install git
echo -e "Personalizing git...";
echo -e "\n# BEGIN" >> ~/.gitconfig;
echo -e "$date_comment" >> ~/.gitconfig
cat git/.gitconfig >> ~/.gitconfig
echo -e "\n# END" >> ~/.gitconfig
green "Success!";
