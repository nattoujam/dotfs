#!/bin/bash
# File              : init-common.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 05/04
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

cd `dirname $0`
path=`pwd`

echo "link $path/.inputrc"
ln -s $path/.inputrc ~/
echo "link $path/.latexmkrc"
ln -s $path/.latexmkrc ~/
echo "link $path/.tmux.conf"
ln -s $path/.tmux.conf ~/

# link wsl settings file (if needs)
read -p "Your platform (wsl1/wsl2/other(def)): " platform
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
