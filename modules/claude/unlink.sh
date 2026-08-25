#!/bin/bash
. "$(dirname "$0")/../../scripts/lib.sh"

cd `dirname $0`
cd ../..
path=`pwd`

unlink_if_needs ~/.claude/CLAUDE.md
unlink_if_needs ~/.claude/statusline.py

for style in "$path"/modules/claude/output-styles/*.md
do
  [ -e "$style" ] || continue
  unlink_if_needs ~/.claude/output-styles/"$(basename "$style")"
done
