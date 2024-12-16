#!/bin/bash
# File              : init-minimal.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 05/04
# Last Modified Date: 2024 12/17
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

# =================
# Main setup script
# =================

cd ../`dirname $0`
path=`pwd`

echo $path

if [[ ! "$path" =~ .*"/.config/nattoujam/dotfs"$ ]]
then
  echo "dotfs must be place under ~/.config/nattoujam/"
  exit 1
fi

sh $path/scripts/unlink.sh

echo "link zsh config file"
sh $path/zsh/init-zsh.sh
