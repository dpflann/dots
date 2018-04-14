### ALIASES
alias gogo="pushd . && cd ~/go";
# alias for TMUX to start in appropriate color setting to accommodate vim colorschemes
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

alias mks="marks"
alias jp="jump"

alias clls="clear && ls"

### SETS
# Set command line editor to vi
set -o vi
shopt -s -o vi

### EXPORTS 
#### GO
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$(go env GOPATH)
export PATH=$PATH:$(go env GOPATH)/bin

# MacPorts Installer addition on 2018-04-07_at_13:53:23: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.
export PATH="$PATH:$HOME/.rvm/bin:/usr/local/go/bin/:$GOPATH/bin:$GOPATH/src/tools" 
export MARKPATH=$HOME/.marks
export PS1="<\[\033[1;36m\]\$(depth)\[\033[m\]\[\033[1;33m\]\$(parse_git_branch)\[\033[m\]>\n\[\033[0;37m\][\@]->\[\033[m\]"
verbosePS1="(\[\033[1;34m\]Location\[\033m\]: \[\033[1;36m\]\$(location)\[\033[m\]\$(parse_git_branch) + \[\033[1;37m\]Time: [\@])\n\[\033[1;36m\]>>>\[\033[m\]"
tersePS1="(\[\033[1;34m\]\$(curdir)/\[\033m\])\[\033[1;36m\]>>>\[\033[m\]"
storagePS1="(\[\033[1;34m\]Location\[\033m\]: \[\033[1;36m\]\$(location)\[\033[m\]\$(parse_git_branch) + \[\033[1;37m\]Time: [\@])\n[Storage: \$(storage)]\n\[\033[1;36m\]>>>\[\033[m\]"

### FUNCTIONS
#### Go
function upgradeGo() {
    CURRENT_GO_VERSION=`go version`;
    TARGET_GO_VERSION="1.10";
    mkdir -p /tmp/upgradeGo
    echo -e `green "upgrading go from $CURRENT_GO_VERSION to $TARGET_GO_VERSION"`;
    echo -e "https://dl.google.com/go/go$TARGET_GO_VERSION.linux-amd64.tar.gz";
    wget "https://dl.google.com/go/go$TARGET_GO_VERSION.linux-amd64.tar.gz"
    sudo tar -C /usr/local -xzf "go$TARGET_GO_VERSION.linux-amd64.tar.gz";
    go version;
    rm "go$TARGET_GO_VERSION.linux-amd64.tar.gz";
}

function install_go_version() {
	#tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
	VERSION=$1;
	OS="darwin";
	ARCH="am64";
	sudo tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
}

function install_go() {
	sudo tar -C /usr/local -xzf $1; 
}

function uninstall_go() {
	sudo rm -rf /usr/local/go; 
}

#### Bash profile and vimrc convenience functions
function rbp() {
	echo -e "Sourcing bash_profile...";
	source ~/.bash_profile;
}

function vbp() {
	vim ~/.bash_profile;
}

function vvc() {
	vim ~/.vimrc
}

#### PS1
##### display 2 levels above and including current diretory: p1/p2/cwd
function depth() {
  pwd=$PWD;
  arrIN=(${pwd//\// });
  len=${#arrIN[@]};
  colorScheme=('\033[1;36m' '\033[1;32m' '\033[1;34m');
  colorEnd='\[\033[m\]';
  index=0;
  path="";
  path_pieces=();
  for (( i=(${len}-1); i > -1 && $index < 3; i--, index=$index+1 ));
    do
      piece="${colorScheme[$index]}/${arrIN[$i]}";
      path_pieces[$index]=$piece;
  done
  lenPath=${#path_pieces[@]};
  for (( i=0; i < ${lenPath}; i++ ));
  do
    path=${path_pieces[$i]}$path;
  done
  path=$path${colorScheme[0]}/;
  echo -e "$path";
}

function location() {
    echo $PWD;
}

function curdir() {
    echo ${PWD##*/}
}

#### git
# get current git branch
function parse_git_branch () {
    br=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
    if [ "$br" != "" ]
    then
        head=`git rev-parse HEAD`;
        #echo " ${br} \[\033[1;33m@\[\033[m\] \[\033[1;42m\]${head}\[\033[m\]";
        echo -e " [\033[1;32m${br}\033[m \033[1;33m@\033[m \033[1;44m${head}\033[m]"
    fi
}

function git-diff-dev() {
    br=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
    git diff develop..$br
}

#### Bookmarking Directories
function jump 
{
    cd -P $MARKPATH/$1 2> /dev/null || echo "No such mark: $1"
}
function mark 
{
    mkdir -p $MARKPATH; ln -s $(pwd) $MARKPATH/$1
}
function unmark 
{
    rm -i $MARKPATH/$1
}
function marks 
{
    ls -l $MARKPATH | sed 's/  / /g' | cut -d' ' -f9- && echo
}

### COLORS
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

### GIT
function gitplo() {
    git pull origin `git rev-parse --abbrev-ref HEAD`
}

function gitpso() {
    red "***** DID YOU RUN ALL THE TESTS? *****";
    read -p "(y/n): " response;
    echo -e "$response";
    if [ "$response" = "y" ]
    then
        green "Yes! Nice work! Now pushing to stash";
        git push origin `git rev-parse --abbrev-ref HEAD`
    else
        red "No problem, running all the tests now...";
        tg;
    fi
}

### GO
#### GOFMT modified files through `git status`
function gowgit() {
    gofiles=`git st | grep -e "modified" | grep -e "\.go" | sed 's/\s\+modified:\s\+//g'`
    for f in ${gofiles[@]};
    do
        echo -e "go goimport'ing $f";
        goimports -w $f;
        echo -e "go fmt'ing $f";
        gofmt -s -w $f;
    done 
}

### VIM
#### Sessions
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

### DOCKER
function dockerclean {
    docker ps --all -q | xargs docker rm -f;
    docker images | grep -v dse | grep -v redis | grep -v IMAGE | grep -v oracle | awk '{print $3}' | xargs docker rmi -f;
}

function dockstop() {
    docker ps -a | awk '{ print $1,$2 }' | grep "$1" | awk '{print $1 }' | xargs -I {} docker stop {}
}
function dockrm() {
    docker ps -a | awk '{ print $1,$2 }' | grep "$1" | awk '{print $1 }' | xargs -I {} docker rm {}
}
function docksrm() {
    dockstop "$1";
    dockrm "$1";
}

function dockstrmi() {
    docker container ls --all --filter name="$1" | awk '{ print $1 }' | xargs -I {} docker stop {};
    docker container ls --all --filter name="$1" | awk '{ print $1 }' | xargs -I {} docker rm {};
    docker container ls --all --filter name="$1" | awk '{ print $1 }' | xargs -I {} docker rm {};
    docker images --all --filter reference="*$1*" --format "{{.ID}}" | xargs -I {} docker rmi {};
}

function dockdang() {
    docker rmi $(docker images -a -f "dangling=true" -q)
    docker system prune
}

function dockVol() {
    sudo du -h /var/lib/docker/volumes;
}
