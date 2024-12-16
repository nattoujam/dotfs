#!/bin/bash
# File              : init-zsh.sh
# Author            : nattoujam <Public.kyuuanago@gmail.com>
# Date              : 2024 12/17
# Last Modified Date: 2024 12/17
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

cd `dirname $0`
path=`pwd`

echo "link $path/.zshrc"
ln -s $path/.zshrc ~/

if [ ! -e ~/.config/dotfs/.zsh_private ]; then
  echo '# type personal zsh config here' > ~/.config/dotfs/.zsh_private
fi
