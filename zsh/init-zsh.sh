#!/bin/bash
# File              : init.sh
# Date              : 2022 09/02
# Last Modified Date: 2022 09/02

cd `dirname $0`
path=`pwd`

echo "link $path/.zshrc"
ln -s $path/.zshrc ~/

if [ ! -e ~/.config/dotfs/.zsh_private ]; then
  echo '# type personale zsh config here' > ~/.config/dotfs/.zsh_private
fi
