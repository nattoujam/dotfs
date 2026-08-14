#!/bin/bash

. "$(dirname "$0")/../../scripts/lib.sh"

cd `dirname $0`
path=`pwd`

echo 'install my commands'
echo 'install nc-notes'
mkdir -p ~/.local/bin
link_if_needs $path/nc-notes.sh ~/.local/bin/nc-notes
