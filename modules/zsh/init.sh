#!/bin/bash
. "$(dirname "$0")/../../scripts/lib.sh"

cd `dirname $0`
cd ../..
path=`pwd`

echo "link $path/modules/zsh/.zshrc"
link_if_needs $path/modules/zsh/.zshrc ~/.zshrc

if [ ! -e $path/modules/zsh/.zsh_private ]; then
  echo '# type personal zsh config here' > $path/modules/zsh/.zsh_private
fi
