#!/bin/bash
# File              : init.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 05/04
# Last Modified Date: 2022 09/02
# Last Modified By  : nattoujam <Public.Kyuuanago@gmail.com>

cd `dirname $0`
path=`pwd`

sh $path/unlink.sh

echo "link $path/.aliases"
ln -s $path/.aliases ~/
echo "link $path/.inputrc"
ln -s $path/.inputrc ~/
echo "link $path/.latexmkrc"
ln -s $path/.latexmkrc ~/
echo "link $path/.tmux.conf"
ln -s $path/.tmux.conf ~/

read -p "use shell ([b]ash/[z]sh/[A]ll): " shell
case "$shell" in
  'b' | 'bash')
    # link bash settings file
    sh $path/bash/init.sh
    ;;
  'z' | 'zsh')
    # link zsh settings file
    sh $path/zsh/init.sh
    ;;
  *)
    # link bash settings file
    sh $path/bash/init.sh
    # link zsh settings file
    sh $path/zsh/init.sh
    ;;
esac

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

echo 'install my commands'
echo 'install ruck'
sudo ln -s $path/bin/ruck.sh /usr/local/bin/ruck
echo 'install git-init-config'
sudo ln -s $path/bin/git-init-config.sh /usr/local/bin/git-init-config
sudo ln -s $path/bin/git-local-nattoujam.sh /usr/local/bin/git-local-nattoujam
