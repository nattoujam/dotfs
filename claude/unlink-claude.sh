#!/bin/bash
unlink_if_needs () {
  if [ -h $1 ]
  then
    echo "unlink: $1"
    unlink $1
  fi
}

unlink_if_needs ~/.claude/CLAUDE.md
unlink_if_needs ~/.claude/statusline.py
