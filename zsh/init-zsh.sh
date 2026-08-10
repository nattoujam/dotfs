#!/bin/bash
. "$(dirname "$0")/../scripts/lib.sh"

cd `dirname $0`
cd ..
path=`pwd`

echo "link $path/.zshrc"
link_if_needs $path/zsh/.zshrc ~/.zshrc

if [ ! -e ~/.config/nattoujam/dotfs/zsh/.zsh_private ]; then
  echo '# type personal zsh config here' > ~/.config/nattoujam/dotfs/zsh/.zsh_private
fi
