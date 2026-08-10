#!/bin/bash
. "$(dirname "$0")/../scripts/lib.sh"

cd `dirname $0`
cd ..
path=`pwd`

echo "link $path/claude/CLAUDE.md"
link_if_needs $path/claude/CLAUDE.md ~/.claude/CLAUDE.md

echo "link $path/claude/statusline.py"
link_if_needs $path/claude/statusline.py ~/.claude/statusline.py
