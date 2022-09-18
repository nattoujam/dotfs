#!/bin/bash
# File              : init.sh
# Author            : nattoujam <Public.Kyuuanago@gmail.com>
# Date              : 2022 09/02
# Last Modified Date: 2022 09/02
# Last Modified By  : nattoujam <Public.Kyuuanago@gmail.com>

cd `dirname $0`
path=`pwd`

echo "link $path/.bash_profile"
ln -s $path/.bash_profile ~/
if [ -e "$HOME/.bash_prompt" ]
then
{
  echo "$HOME/.bash_prompt is exists."
  read -p "override ok? (y/N): " yn
  case "$yn" in
    [yY]*)
      {
        echo "override $HOME/.bash_prompt"
        cp $path/.bash_prompt_org $HOME/.bash_prompt
      };;
    # *) echo "abort";;
  esac
}
else
{
  echo "copy $HOME/.bash_prompt"
  cp $path/.bash_prompt_org $HOME/.bash_prompt
}
fi
