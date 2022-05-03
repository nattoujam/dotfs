alias pbcopy='xsel --clipboard --input'
alias rm='rm -i'
alias lp='leafpad'
alias ..='cd ..'

#kotlin
alias kotlinjar='kotlinc -include-runtime -d'

# ========
# = typo =
# ========
alias c='cd'
alias bim='vim'
alias ivm='vim'

# ===========
# = windows =
# ===========
# explorer
# open explorer to current directory
# $ exp .
alias exp='explorer.exe'

# ============
# = functoin =
# ============
# cd and ls
# https://qiita.com/b4b4r07/items/8cf5d1c8b3fbfcf01a5d
cd () {
  builtin cd "$@" && ls
}
