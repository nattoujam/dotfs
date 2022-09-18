#!/bin/bash
# File              : uninstall.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 05/04
# Last Modified Date: 2022 05/04
# Last Modified By  : nattoujam <Public.Kyuuanago@gmail.com>

cd `dirname $0`
path=`pwd`

unlink_if_needs () {
  if [ -e $1 ]
  then
    if [ $2 -eq 1 ]
    then
      echo "sudo unlink: $1"
      sudo unlink $1
    else
      echo "unlink: $1"
      unlink $1
    fi
  fi
}

echo 'unlink dot files'
unlink_if_needs ~/.aliases 0
unlink_if_needs ~/.inputrc 0
unlink_if_needs ~/.latexmkrc 0
unlink_if_needs ~/.tmux.conf 0
unlink_if_needs ~/.wsl1 0
unlink_if_needs ~/.wsl2 0

echo 'unlink bash files'
sh $path/bash/unlink.sh

echo 'unlink zsh files'
sh $path/zsh/unlink.sh

echo 'unlink my commands'
unlink_if_needs /usr/local/bin/ruck 1
unlink_if_needs /usr/local/bin/git-init-config 1
unlink_if_needs /usr/local/bin/git-local-nattoujam 1
