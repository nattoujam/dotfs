# dotfs
## Setup
```bash
sudo apt install zsh
chsh -s `which zsh`
git clone https://github.com/nattoujam/dotfs.git ~/.config --branch zsh
bash ~/.config/dotfs/init.sh

zsh
. Z
zplug install
```

## Remove
```bash
bash ~/.config/dotfs/unlink.sh
```
