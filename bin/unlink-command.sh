#!/bin/bash
# File              : unlink-command.sh
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

unlink_if_needs /usr/local/bin/ruck 1
unlink_if_needs /usr/local/bin/git-init-config 1
unlink_if_needs /usr/local/bin/git-local-nattoujam 1
