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

has_cmd () {
  command -v "$1" >/dev/null 2>&1
}

# os_family
# /etc/os-release の ID/ID_LIKE から distro family を判定して echo する。
# 戻り値: arch | debian | unknown
os_family () {
  if [ -r /etc/os-release ]
  then
    (
      . /etc/os-release
      case "${ID}:${ID_LIKE:-}" in
        *arch*|*cachyos*) echo arch ;;
        *ubuntu*|*debian*) echo debian ;;
        *) echo unknown ;;
      esac
    )
  else
    echo unknown
  fi
}

# pkg_install <arch_pkg> <debian_pkg>
# distro family ごとのパッケージ名を渡してインストールする。
# 対応distroにパッケージが存在しない場合は空文字を渡せばスキップする。
pkg_install () {
  arch_pkg=$1
  debian_pkg=$2
  family=$(os_family)

  case "$family" in
    arch)
      if [ -n "$arch_pkg" ]
      then
        sudo pacman -S --needed --noconfirm "$arch_pkg"
      fi
      ;;
    debian)
      if [ -n "$debian_pkg" ]
      then
        sudo apt-get install -y "$debian_pkg"
      fi
      ;;
    *)
      echo "pkg_install: unknown os family, skip ($arch_pkg / $debian_pkg)"
      ;;
  esac
}
