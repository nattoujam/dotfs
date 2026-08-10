#!/bin/bash
# File              : init-command.sh
# Author            : nattoujam <Public.kyuuanago@gmail.com>
# Date              : 2023 12/31
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

cd `dirname $0`
path=`pwd`

echo 'install my commands'
echo 'install nc-notes'
mkdir -p ~/.local/bin
ln -s $path/nc-notes.sh ~/.local/bin/nc-notes
