#!/bin/bash
# 外部コマンドのインストール処理を書く

cd `dirname $0`
path=`pwd`

while read -r url
do
  case "$url" in
    ''|'#'*) continue ;;
  esac
  echo "install: $url"
  curl -fsSL "$url" | sh
done < "$path/installers.conf"

PS1_SOURCE_LINE='[ -f ~/.config/nattoujam/ps1/current ] && source ~/.config/nattoujam/ps1/current'
PS1_PRIVATE_FILE="$path/../zsh/.zsh_private"
touch "$PS1_PRIVATE_FILE"
grep -qF "$PS1_SOURCE_LINE" "$PS1_PRIVATE_FILE" || echo "$PS1_SOURCE_LINE" >> "$PS1_PRIVATE_FILE"
