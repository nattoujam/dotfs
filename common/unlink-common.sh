#!/bin/bash
# File              : unlink-common.sh
# Author            : nattoujam <Public.kyuuanago@gmail.com>
# Date              : 2023 12/31
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

unlink_if_needs () {
  if [ -h $1 ]
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

unlink_if_needs ~/.inputrc 0
unlink_if_needs ~/.latexmkrc 0
unlink_if_needs ~/.tmux.conf 0
unlink_if_needs ~/.wsl1 0
unlink_if_needs ~/.wsl2 0
