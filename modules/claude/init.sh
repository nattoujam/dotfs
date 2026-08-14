#!/bin/bash
. "$(dirname "$0")/../../scripts/lib.sh"

cd `dirname $0`
cd ../..
path=`pwd`

echo "link $path/modules/claude/CLAUDE.md"
link_if_needs $path/modules/claude/CLAUDE.md ~/.claude/CLAUDE.md

echo "link $path/modules/claude/statusline.py"
link_if_needs $path/modules/claude/statusline.py ~/.claude/statusline.py
