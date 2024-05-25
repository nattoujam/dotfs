#!/bin/sh
cd `dirname $0`
path=`pwd`
echo $path

mkdir -p ~/.config/alacritty
ln -s $path/alacirtty.toml ~/.config/alacritty/alacritty.toml
