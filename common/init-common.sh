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
echo "link $path/.config/tmux/tmux.conf"
mkdir -p ~/.config/tmux
ln -s $path/common/tmux.conf ~/.config/tmux/

echo 'setup git config'
git config --global user.name "nattoujam"
git config --global user.email "28142852+nattoujam@users.noreply.github.com"
git config --global core.editor "vim"
git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto
git config --global core.quotepath false
git config --global core.autocrlf input
