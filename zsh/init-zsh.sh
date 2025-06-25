#!/bin/bash
cd `dirname $0`
cd ..
path=`pwd`

echo "link $path/.zshrc"
ln -s $path/zsh/.zshrc ~/

if [ ! -e ~/.config/nattoujam/dotfs/zsh/.zsh_private ]; then
  echo '# type personal zsh config here' > ~/.config/nattoujam/dotfs/zsh/.zsh_private
fi
