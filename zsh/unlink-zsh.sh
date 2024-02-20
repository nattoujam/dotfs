#!/bin/bash
# File              : unlink.sh
# Date              : 2022 09/02
# Last Modified Date: 2022 09/02

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

unlink_if_needs ~/.zshrc 0
