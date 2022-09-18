#!/bin/bash
# File              : unlink.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 09/02
# Last Modified Date: 2022 09/02
# Last Modified By  : nattoujam <Public.Kyuuanago@gmail.com>

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

unlink_if_needs ~/.bash_profile 0
