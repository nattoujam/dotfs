#!/bin/bash
# File              : init.sh
# Date              : 2022 09/02
# Last Modified Date: 2022 09/02

cd `dirname $0`
path=`pwd`

echo "link $path/.zshrc"
ln -s $path/.zshrc ~/
