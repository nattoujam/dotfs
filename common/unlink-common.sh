#!/bin/bash
# File              : unlink-common.sh
# Author            : nattoujam <Public.kyuuanago@gmail.com>
# Date              : 2023 12/31
# Last Modified Date: 2023 12/31
# Last Modified By  : nattoujam <Public.kyuuanago@gmail.com>

. "$(dirname "$0")/../scripts/lib.sh"

unlink_if_needs ~/.inputrc 0
unlink_if_needs ~/.config/tmux/tmux.conf 0
