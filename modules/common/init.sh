#!/bin/bash
. "$(dirname "$0")/../../scripts/lib.sh"

cd `dirname $0`
cd ../..
path=`pwd`

echo "link $path/.inputrc"
link_if_needs $path/modules/common/.inputrc ~/.inputrc
echo "link $path/.config/tmux/tmux.conf"
mkdir -p ~/.config/tmux
link_if_needs $path/modules/common/tmux.conf ~/.config/tmux/tmux.conf

echo 'setup git config'
git config --global user.name "nattoujam"
git config --global user.email "28142852+nattoujam@users.noreply.github.com"
git config --global core.editor "vim"
git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto
git config --global core.quotepath false
git config --global core.autocrlf input

echo "os family: $(os_family)"

echo 'install lazygit'
if ! has_cmd lazygit
then
  if [ "$(os_family)" = "arch" ]
  then
    pkg_install lazygit ""
  else
    LAZYGIT_ARCH=$(uname -m | sed -e 's/aarch64/arm64/')
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit -D -t /usr/local/bin/
    rm -f /tmp/lazygit.tar.gz /tmp/lazygit
  fi
fi

echo 'install delta'
has_cmd delta || pkg_install git-delta git-delta

echo "link $path/modules/common/config.yml -> ~/.config/lazygit/config.yml"
mkdir -p ~/.config/lazygit
link_if_needs $path/modules/common/config.yml ~/.config/lazygit/config.yml

echo 'install asdf'
if ! has_cmd asdf
then
  ASDF_ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')
  ASDF_VERSION=$(curl -s "https://api.github.com/repos/asdf-vm/asdf/releases/latest" | grep -Po '"tag_name": *"\K[^"]*')
  curl -Lo /tmp/asdf.tar.gz "https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/asdf-${ASDF_VERSION}-linux-${ASDF_ARCH}.tar.gz"
  tar xf /tmp/asdf.tar.gz -C /tmp asdf
  sudo install /tmp/asdf -D -t /usr/local/bin/
  rm -f /tmp/asdf.tar.gz /tmp/asdf
fi
