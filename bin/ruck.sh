#!/bin/bash
# git remote repository update checker

if [ $# == 2 ]; then
  path=$1
  branch=$2
elif [ $# == 1 ]; then
  path=$1
  branch='master'
else
  echo '$ ruck <repository path> [branch]'
  echo
  echo '  [option]'
  echo '    branch : default master'
  echo
  echo '  [return]'
  echo '    up to date    : 0'
  echo '    update needed : 1'
  echo '    some error    : 2'
  exit 2
fi

cd $path
remote=`git ls-remote origin $branch | awk '{print $1}'`
local_b=`git log -1 $branch | awk 'NR==1 {print $2}'`

# echo $remote
# echo $local_b

if [ $remote = $local_b ]; then
  # up to date
  p=`git rev-parse --show-toplevel`
  echo "`basename $p` up to date"
  exit 0
else
  # new version exists
  echo Find new version! need to update
  exit 1
fi
