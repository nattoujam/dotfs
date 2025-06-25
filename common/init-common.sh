#!/bin/bash
# File              : init-common.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 05/04
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

cd `dirname $0`
cd ..
path=`pwd`

echo "link $path/.inputrc"
ln -s $path/common/.inputrc ~/
echo "link $path/.latexmkrc"
ln -s $path/common/.latexmkrc ~/
echo "link $path/.config/tmux/tmux.conf"
mkdir -p ~/.config/tmux
ln -s $path/common/tmux.conf ~/.config/tmux/

# link wsl settings file (if needs)
read -p "Your platform (wsl1/wsl2/other(def)): " platform
case "$platform" in
  "wsl1" )
    {
      echo "select: wsl1"
      ln -s $path/common/.wsl1 ~/
    };;
  "wsl2" )
    {
      echo "select: wsl2"
      ln -s $path/common/.wsl2 ~/
    };;
  * ) 
    {
      echo "select: other"
    };;
esac
