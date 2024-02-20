#!/bin/bash
# File              : init.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 05/04
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

# =================
# Main setup script
# =================

cd `dirname $0`
path=`pwd`

if [[ ! "$path" =~ .*"/.config/nattoujam/dotfs"$ ]]
then
  echo 'dotfs must be place under ~/.config/nattoujam/'
  exit 1
fi

sh $path/unlink.sh

echo "link common config file"
$path/common/init-common.sh

echo "link zsh config file"
sh $path/zsh/init-zsh.sh

echo 'install my command'
sh $path/bin/init-command.sh

echo "install other"
sh $path/common/init-other.sh
