#!/bin/bash
cd `dirname $0`
cd ..
path=`pwd`

echo "link $path/claude/CLAUDE.md"
ln -s $path/claude/CLAUDE.md ~/.claude/CLAUDE.md

echo "link $path/claude/statusline.py"
ln -s $path/claude/statusline.py ~/.claude/statusline.py
