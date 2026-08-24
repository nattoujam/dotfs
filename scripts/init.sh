#!/bin/bash

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

echo "using profile: $profile ($profile_file)"

sh "$path/scripts/unlink.sh" "$profile"

while read -r module
do
  case "$module" in
    ''|'#'*) continue ;;
  esac
  echo "== init: $module =="
  sh "$path/modules/$module/init.sh"
done < "$profile_file"
