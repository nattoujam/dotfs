#!/bin/sh
# File              : lib.sh
# 各 init-*.sh / unlink-*.sh から source される共通関数

unlink_if_needs () {
  target=$1
  use_sudo=${2:-0}

  if [ -h "$target" ]
  then
    if [ "$use_sudo" -eq 1 ]
    then
      echo "sudo unlink: $target"
      sudo unlink "$target"
    else
      echo "unlink: $target"
      unlink "$target"
    fi
  fi
}

# link_if_needs <src> <dest> [use_sudo]
# dest は常にリンク先ファイルのフルパスを渡すこと(ディレクトリ渡しは不可)。
# 既に src を指す symlink なら何もしない。別物を指す symlink なら張り替える。
# symlinkでない実体が既にあれば、誤って上書きしないようスキップする。
link_if_needs () {
  src=$1
  dest=$2
  use_sudo=${3:-0}

  if [ -h "$dest" ]
  then
    if [ "$(readlink "$dest")" = "$src" ]
    then
      echo "already linked: $dest"
      return 0
    fi
    echo "relink (stale symlink): $dest"
    if [ "$use_sudo" -eq 1 ]
    then
      sudo unlink "$dest"
    else
      unlink "$dest"
    fi
  elif [ -e "$dest" ]
  then
    echo "skip (already exists, not a symlink): $dest"
    return 1
  fi

  if [ "$use_sudo" -eq 1 ]
  then
    echo "sudo link: $src -> $dest"
    sudo ln -s "$src" "$dest"
  else
    echo "link: $src -> $dest"
    ln -s "$src" "$dest"
  fi
}
