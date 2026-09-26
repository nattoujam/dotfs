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

echo 'link weekly-review'
mkdir -p ~/.local/bin ~/.config/systemd/user
link_if_needs $path/modules/claude/weekly-review/run.sh ~/.local/bin/claude-weekly-review
for unit in "$path"/modules/claude/weekly-review/*.service "$path"/modules/claude/weekly-review/*.timer
do
  [ -e "$unit" ] || continue
  link_if_needs "$unit" ~/.config/systemd/user/"$(basename "$unit")"
done
if has_cmd systemctl && systemctl --user show-environment >/dev/null 2>&1
then
  systemctl --user daemon-reload
  for timer in "$path"/modules/claude/weekly-review/*.timer
  do
    [ -e "$timer" ] || continue
    systemctl --user enable --now "$(basename "$timer")"
  done
fi
