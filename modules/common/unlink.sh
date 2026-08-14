#!/bin/bash

. "$(dirname "$0")/../../scripts/lib.sh"

unlink_if_needs ~/.inputrc 0
unlink_if_needs ~/.config/tmux/tmux.conf 0
unlink_if_needs ~/.config/lazygit/config.yml 0
