#!/bin/bash
# File              : init-command.sh
# Author            : nattoujam <Public.kyuuanago@gmail.com>
# Date              : 2023 12/31
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

cd `dirname $0`
path=`pwd`

echo 'install my commands'
echo 'install ruck'
sudo ln -s $path/ruck.sh /usr/local/bin/ruck
echo 'install git-init-config'
sudo ln -s $path/git-init-config.sh /usr/local/bin/git-init-config
sudo ln -s $path/git-local-nattoujam.sh /usr/local/bin/git-local-nattoujam
