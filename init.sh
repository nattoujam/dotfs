#!/bin/bash
# File              : install.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 05/04
# Last Modified Date: 2022 05/04
# Last Modified By  : nattoujam <Public.Kyuuanago@gmail.com>

cd `dirname $0`
path=`pwd`

sh $path/uninstall.sh

echo "link $path/.aliases"
ln -s $path/.aliases ~/
echo "link $path/.bash_profile"
ln -s $path/.bash_profile ~/
echo "link $path/.inputrc"
ln -s $path/.inputrc ~/
echo "link $path/.latexmkrc"
ln -s $path/.latexmkrc ~/
echo "link $path/.tmux.conf"
ln -s $path/.tmux.conf ~/
if [ -e "$HOME/.bash_prompt" ]
then
{
  echo "$HOME/.bash_prompt is exists."
  read -p "override ok? (y/N): " yn
  case "$yn" in
    [yY]*)
      {
        echo "override $HOME/.bash_prompt"
        cp $path/.bash_prompt_org $HOME/.bash_prompt
      };;
    # *) echo "abort";;
  esac
}
else
{
  echo "copy $HOME/.bash_prompt"
  cp $path/.bash_prompt_org $HOME/.bash_prompt
}
fi

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
