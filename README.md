# dotfs
## Setup
```bash
git clone https://github.com/nattoujam/dotfs.git ~/dotfs
cd ~/dotfs
bash scripts/bootstrap.sh
bash scripts/init.sh <profile>

zsh
. Z
```

`scripts/bootstrap.sh`はzshの導入とデフォルトシェルの変更を行う(`scripts/init.sh`より前に一度だけ実行する)。

`<profile>`には`machines/`配下にある設定ファイル名(拡張子`.conf`を除いたもの)を指定する。省略した場合は`hostname`と同名のプロファイルを使う。利用可能なプロファイルは`ls machines/`で確認できる。

導入するモジュールはプロファイルごとの`machines/<profile>.conf`に列挙されており、1行1モジュール名(`modules/`配下のディレクトリ名)を書く。

## Remove
```bash
bash scripts/unlink.sh <profile>
```
