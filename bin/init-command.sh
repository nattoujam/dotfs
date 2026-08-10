#!/bin/bash
# File              : init-command.sh
# Author            : nattoujam <Public.kyuuanago@gmail.com>
# Date              : 2023 12/31
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

. "$(dirname "$0")/../scripts/lib.sh"

cd `dirname $0`
path=`pwd`

echo 'install my commands'
echo 'install nc-notes'
mkdir -p ~/.local/bin
link_if_needs $path/nc-notes.sh ~/.local/bin/nc-notes
