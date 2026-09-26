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

for rule in "$path"/modules/claude/rules/*.md
do
  [ -e "$rule" ] || continue
  unlink_if_needs ~/.claude/rules/"$(basename "$rule")"
done

if has_cmd systemctl && systemctl --user show-environment >/dev/null 2>&1
then
  for timer in "$path"/modules/claude/weekly-review/*.timer
  do
    [ -e "$timer" ] || continue
    systemctl --user disable --now "$(basename "$timer")" 2>/dev/null || true
  done
fi
unlink_if_needs ~/.local/bin/claude-weekly-review
unlink_if_needs ~/.local/bin/claude-log-backup
for unit in "$path"/modules/claude/weekly-review/*.service "$path"/modules/claude/weekly-review/*.timer
do
  [ -e "$unit" ] || continue
  unlink_if_needs ~/.config/systemd/user/"$(basename "$unit")"
done
if has_cmd systemctl && systemctl --user show-environment >/dev/null 2>&1
then
  systemctl --user daemon-reload
fi
