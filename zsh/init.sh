#!/bin/bash
# File              : init.sh
# Date              : 2022 09/02
# Last Modified Date: 2022 09/02

cd `dirname $0`
cd ..
path=`pwd`

sh $path/uninstall.sh

echo "link $path/.aliases"
ln -s $path/.aliases ~/
echo "link $path/.inputrc"
ln -s $path/.inputrc ~/
echo "link $path/.latexmkrc"
ln -s $path/.latexmkrc ~/
echo "link $path/.tmux.conf"
ln -s $path/.tmux.conf ~/
echo "link $path/zsh/.zshrc"
ln -s $path/zsh/.zshrc ~/

read -p "Your platform (wsl1/wsl2/other): " platform
case "$platform" in
  "wsl1" )
    {
      echo "select: wsl1"
      ln -s $path/.wsl1 ~/
    };;
  "wsl2" )
    {
      echo "select: wsl2"
      ln -s $path/.wsl2 ~/
    };;
  * ) 
    {
      echo "select: other"
    };;
esac

echo install my commands
echo install ruck
sudo ln -s $path/bin/ruck.sh /usr/local/bin/ruck
echo install git-init-config
sudo ln -s $path/bin/git-init-config.sh /usr/local/bin/git-init-config
sudo ln -s $path/bin/git-local-nattoujam.sh /usr/local/bin/git-local-nattoujam
