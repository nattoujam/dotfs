#!/bin/bash
# File              : uninstall.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 05/04
# Last Modified Date: 2022 05/04
# Last Modified By  : nattoujam <Public.Kyuuanago@gmail.com>

echo uninstall dot files
unlink ~/.bash_aliases
unlink ~/.bash_profile
unlink ~/.inputrc
unlink ~/.latexmkrc
unlink ~/.tmux.conf
unlink ~/.wsl1
unlink ~/.wsl2

echo uninstall my commands
sudo unlink /usr/local/bin/ruck
sudo unlink /usr/local/bin/git-init-config
