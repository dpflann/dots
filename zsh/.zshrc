# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)
source $ZSH/oh-my-zsh.sh

######### TOOL INIT

# atuin -- shell history. Must come before any keybinding overrides, since
# `atuin init` rebinds Up/Ctrl-R.
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion";  # This loads nvm bash_completion

# asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

######### COLORS

function echoColors() {
  echo -e "\033[0mCOLOR_NC (No color)"
  echo -e "\033[1;37m1;37m=COLOR_WHITE\t\033[0;30m0;30m=COLOR_BLACK"
  echo -e "\033[0;34m0;34m=COLOR_BLUE\t\033[1;34m1;34m=COLOR_LIGHT_BLUE"
  echo -e "\033[0;32m0;32m=COLOR_GREEN\t\033[1;32m1;32m=COLOR_LIGHT_GREEN"
  echo -e "\033[0;36m0;36m=COLOR_CYAN\t\033[1;36m1;36m=COLOR_LIGHT_CYAN"
  echo -e "\033[0;31m0;31m=COLOR_RED\t\033[1;31m1;31m=COLOR_LIGHT_RED"
  echo -e "\033[0;35m0;35m=COLOR_PURPLE\t\033[1;35m1;35m=COLOR_LIGHT_PURPLE"
  echo -e "\033[0;33m0;33m=COLOR_YELLOW\t\033[1;33m1;33m=COLOR_LIGHT_YELLOW"
  echo -e "\033[1;30m1;30m=COLOR_GRAY\t\033[0;37m0;37m=COLOR_LIGHT_GRAY"

  echo -e "\033[0mCOLOR_NC (No color)"
  echo -e "\033[1;47m1;47m=COLOR_WHITE\t\033[0;40m0;40m=COLOR_BLACK"
  echo -e "\033[0;44m0;44m=COLOR_BLUE\t\033[1;44m1;44m=COLOR_LIGHT_BLUE"
  echo -e "\033[0;42m0;42m=COLOR_GREEN\t\033[1;42m1;42m=COLOR_LIGHT_GREEN"
  echo -e "\033[0;46m0;46m=COLOR_CYAN\t\033[1;46m1;46m=COLOR_LIGHT_CYAN"
  echo -e "\033[0;41m0;41m=COLOR_RED\t\033[1;41m1;41m=COLOR_LIGHT_RED"
  echo -e "\033[0;45m0;45m=COLOR_PURPLE\t\033[1;45m1;45m=COLOR_LIGHT_PURPLE"
  echo -e "\033[0;43m0;43m=COLOR_YELLOW\t\033[1;43m1;43m=COLOR_LIGHT_YELLOW"
  echo -e "\033[1;40m1;40m=COLOR_GRAY\t\033[0;47m0;47m=COLOR_LIGHT_GRAY"
}

function green() {
    echo -e "\033[1;32m$@\033[m"
}

function red() {
    echo -e "\033[1;31m$@\033[m"
}

function blue() {
    echo -e "\033[1;34m$@\033[m"
}

######### ALIASES

alias tmux="TERM=xterm-256color tmux"

# alias for moving around the depths of directories
alias cd.="cd .."
alias cd..="cd ../.."
alias cd...="cd ../../.."
alias cd....="cd ../../../.."
alias cd.....="cd ../../../../.."

alias vO="vim -O"  # open the subsequent files in with vertical splits
alias vo="vim -o"  # open the subsequent files in vim with horizontal splits
alias vp="vim -p"  # open the subsequent files in tabs
alias vs="vim -S"
alias vss="vim -S ~/.vim/sessions/"

######### VIM SESSIONS

function vsls() {
    ls -l ~/.vim/sessions
}
function vsd() {
    rm ~/.vim/sessions/$1
}
function vsd-all() {
    rm ~/.vim/sessions/*
}
function vso() {
    vim -S "~/.vim/sessions/$1"
}

######### CONFIG RELOAD

function rzsh() {
    echo -e "Source ~/.zshrc...";
    source ~/.zshrc;
}

function vzsh() {
    vim ~/.zshrc;
    rzsh;
}

function rtmux() {
    tmux source-file ~/.tmux.conf;
}

######### GIT

function git_diff_names() {
    git diff --name-only master
}

######### DOCKER

function dexec() {
    if [ $# -lt 1 ]; then
      echo "Usage: dexec <container> [command...]"
      return 1
    fi

    local container=$1
    shift

    # Default to bash if no command provided
    if [ $# -eq 0 ]; then
      docker exec -it "$container" bash
    else
      docker exec -it "$container" "$@"
    fi
}

######### SSH

function init_ssh_key() {
    echo "eval'ing ssh-agent...";
    eval "$(ssh-agent -s)";
    echo "adding key...";
    ssh-add ~/.ssh/id_ed25519;
}

######### CLAUDE CODE

export CLAUDE_CODE_USE_BEDROCK=0
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000
export CLAUDE_CODE_DISABLE_MOUSE_CLICKS=1

######### MACHINE-LOCAL

# Per-machine additions that should not live in a public repo: work
# functions, account IDs, credentials, client-specific helpers. Untracked
# by design -- see .gitignore.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
