#!/bin/bash

. "$(dirname "$0")/../../scripts/lib.sh"

cd `dirname $0`
path=`pwd`

echo 'install trash-cli'
has_cmd trash-put || pkg_install trash-cli trash-cli

if has_cmd trash-put
then
  RM_ALIAS_LINE="alias rm='trash-put'"
else
  RM_ALIAS_LINE="alias rm='rm -i'"
fi

PRIVATE_FILE="$path/../zsh/.zsh_private"
touch "$PRIVATE_FILE"
grep -v "^alias rm=" "$PRIVATE_FILE" > "$PRIVATE_FILE.tmp" && mv "$PRIVATE_FILE.tmp" "$PRIVATE_FILE"
echo "$RM_ALIAS_LINE" >> "$PRIVATE_FILE"
