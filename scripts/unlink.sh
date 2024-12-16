#!/bin/bash
# File              : unlink.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 05/04
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

cd `dirname $0`
path=`pwd`

echo 'unlink common config files'
sh $path/common/unlink-common.sh

echo 'unlink zsh config files'
sh $path/zsh/unlink-zsh.sh

echo 'unlink my command'
sh $path/bin/unlink-command.sh
