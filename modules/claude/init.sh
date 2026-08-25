#!/bin/bash
. "$(dirname "$0")/../../scripts/lib.sh"

cd `dirname $0`
cd ../..
path=`pwd`

echo "link $path/modules/claude/CLAUDE.md"
link_if_needs $path/modules/claude/CLAUDE.md ~/.claude/CLAUDE.md

echo "link $path/modules/claude/statusline.py"
link_if_needs $path/modules/claude/statusline.py ~/.claude/statusline.py

echo 'link output styles'
mkdir -p ~/.claude/output-styles
for style in "$path"/modules/claude/output-styles/*.md
do
  [ -e "$style" ] || continue
  link_if_needs "$style" ~/.claude/output-styles/"$(basename "$style")"
done

echo 'link rules'
mkdir -p ~/.claude/rules
for rule in "$path"/modules/claude/rules/*.md
do
  [ -e "$rule" ] || continue
  link_if_needs "$rule" ~/.claude/rules/"$(basename "$rule")"
done
