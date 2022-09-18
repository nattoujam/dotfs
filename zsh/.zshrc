# default settings
# {{{

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# }}}

# zsh built-in module
# ===================
# {{{

# move all file in current directory
# ----------------------------------
autoload -Uz zmv
alias zmv='noglob zmv -W'

# git
# ---
# https://git-scm.com/book/ja/v2/%E4%BB%98%E9%8C%B2-A%3A-%E3%81%9D%E3%81%AE%E4%BB%96%E3%81%AE%E7%92%B0%E5%A2%83%E3%81%A7%E3%81%AEGit-Zsh%E3%81%A7Git%E3%82%92%E4%BD%BF%E3%81%86
# https://qiita.com/umasoya/items/f3bd6cffd418f3830b75
autoload -Uz compinit && compinit
autoload -Uz vcs_info
setopt prompt_subst  # プロンプト表示する度に変数を展開
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{green}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{207}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd(){ vcs_info }

# prompt
# ------

# 直前の返り値によって色変更
local p_color="%(?.%F{white}.%F{red})"
autoload -Uz promptinit && promptinit
prompt_daily_setup() {  # prompt_<style name>_setup() {
  PROMPT="%F{magenta}%n%f: %F{cyan}%~%f"$'\n'"$p_color"'%#%f '
  RPROMPT='${memotxt}''${vcs_info_msg_0_}'' ($?) %F{229}[%T]%f'
}
prompt_themes+=( daily )

# }}}

# zsh plugin
# ==========================================
# using pulugin manager: zplug
# > https://github.com/zplug/zplug
# ==========================================
# {{{

if [ ! -e ~/.zplug/init.zsh ]
then
  # install zplug
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
  sleep 0.1
fi

source ~/.zplug/init.zsh

# history common settings
# --------------
# https://github.com/sorin-ionescu/prezto/tree/master/modules/history
zplug "modules/history", from:prezto

# drectory common settings
# ------------------------
# https://github.com/sorin-ionescu/prezto/tree/master/modules/directory
zplug "modules/directory", from:prezto

# }}}

# other function
# ==============
# {{{

# memo
# ----
function memo() {
    if [ $# -eq 0 ]
    then
        unset memotxt
        return
    fi
    for str in $@
    do
    memotxt="${memotxt} ${str}"
    done
}

# }}}

# prompt
# ======
# {{{

prompt daily

# }}}

# load other settings file
# ========================
# {{{

if [ -e ~/.aliases ]; then
  . ~/.aliases
fi

# }}}

