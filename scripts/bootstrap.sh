#!/bin/bash

cd `dirname $0`
cd ..
path=`pwd`

. "$path/scripts/lib.sh"

echo 'install zsh'
has_cmd zsh || pkg_install zsh zsh

ZSH_PATH=$(command -v zsh)

if [ "$SHELL" != "$ZSH_PATH" ]
then
  echo "change default shell to $ZSH_PATH"
  chsh -s "$ZSH_PATH"
fi
