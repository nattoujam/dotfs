#!/bin/bash
# File              : hoge.sh
# Author            : nattoujam <Public.kyuuanago@gmail.com>
# Date              : 2023 12/31
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

p=`pwd`
if [[ ! "$p" =~ .*"/zsh"$ ]]
then
  echo 'unmatch'
  exit
else
  echo 'match'
fi

echo 'aaa'
