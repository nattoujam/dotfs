#!/bin/sh
. "$(dirname "$0")/../scripts/lib.sh"

cd `dirname $0`
cd ..
path=`pwd`
echo $path

mkdir -p ~/.config/alacritty
link_if_needs $path/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
