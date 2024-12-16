# dotfs
## Setup
```bash
sudo apt install zsh
chsh -s `which zsh`

mkdir -p ~/.config/nattoujam
git clone https://github.com/nattoujam/dotfs.git ~/.config/nattoujam --branch zsh
bash ~/.config/nattoujam/dotfs/scripts/init.sh

zsh
. Z
zplug install
```

### minimal install
```bash
./dotfs/scripts/init-minimal.sh
```

## Remove
```bash
bash ~/.config/dotfs/nattoujam/scripts/unlink.sh
```
