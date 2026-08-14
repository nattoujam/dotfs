#!/bin/bash
# File              : unlink.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 05/04
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

cd `dirname $0`
cd ..
path=`pwd`

. "$path/scripts/lib.sh"

profile=$1
if [ -z "$profile" ]
then
  profile=`hostname`
fi

profile_file="$path/machines/${profile}.conf"

if [ ! -f "$profile_file" ]
then
  echo "machine profile not found: $profile_file"
  echo "usage: $0 <profile>"
  echo "available profiles:"
  ls "$path/machines" | sed -e 's/\.conf$//' -e 's/^/  /'
  exit 1
fi

while read -r module
do
  case "$module" in
    ''|'#'*) continue ;;
  esac
  echo "== unlink: $module =="
  sh "$path/modules/$module/unlink.sh"
done < "$profile_file"
