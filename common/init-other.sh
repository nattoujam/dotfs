#!/bin/bash
# File              : init-other.sh
# Author            : nattoujam <Public.kyuuanago@gmail.com>
# Date              : 2023 12/31
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

cd `dirname $0`
path=`pwd`

echo 'common command'
sudo apt update && sudo apt install git vim curl

if [ "$OSTYPE" == 'linux-gnu' ]
then
  echo 'install lazy-git'
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' |  sed -E 's/.*"v*([^"]+)".*/\1/')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit

  rm ./lazygit.tar.gz

  echo 'install delta'
  DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep '"tag_name":' |  sed -E 's/.*"v*([^"]+)".*/\1/')
  curl -Lo git-delta_amd64.deb "https://github.com/dandavison/delta/releases/download/latest/git-delta_${DELTA_VERSION}_amd64.deb"
  sudo dpkg install ./git-delta_amd64.dev

  rm ./git-delta_amd64.deb

  echo "link $path/.config/lazygit/config.yml"
  if [ -e ~/.config/lazygit/config.yml ]
  then
    rm ~/.config/lazygit/config.yml
  fi
  ln -s $path/config.yml ~/.config/lazygit/
fi

echo 'install asdf'
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
