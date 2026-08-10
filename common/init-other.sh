#!/bin/bash
# File              : init-other.sh
# Author            : nattoujam <Public.kyuuanago@gmail.com>
# Date              : 2023 12/31
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

. "$(dirname "$0")/../scripts/lib.sh"

cd `dirname $0`
cd ..
path=`pwd`

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

echo "link $path/common/config.yml -> ~/.config/lazygit/config.yml"
mkdir -p ~/.config/lazygit
link_if_needs $path/common/config.yml ~/.config/lazygit/config.yml

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

