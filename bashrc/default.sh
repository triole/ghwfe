function show_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

function autosudo() {
    if [[ "$(id -u)" != "0" && -n "$(which sudo)" ]]; then echo "sudo "; fi
}

export PS1="\u@\h \033[0;93m\w\033[0m \$(show_git_branch) \\033[1;92m\$\\033[0m "
if [[ "$(whoami)" == "root" ]]; then
    export PS1="\u@\h \033[0;93m\w\033[0m \$(show_git_branch) \\033[1;31m# \\033[0m "
fi

alias ..="cd .."
alias cl="clear"
alias env="env | sort"
alias gita="git add"
alias gitd="git diff"
alias gitc="git commit -m"
alias gitl="git log"
alias gitp="git pull"
alias gits="git status"
alias grep="grep --color"
alias lsblk="lsblk -o name,maj:min,ro,rm,type,size,mountpoint,label,uuid,pttype,parttypename,type,vendor,model,serial"
alias p="python"
alias pm="python manage.py"
alias pkl="pkill -9"
alias psa='function _psa(){ if [[ -n "${1}" ]]; then ps faux | grep "${1}" | grep -v "grep.*${1}"; else ps faux; fi };_psa'
alias tailf="tail -F"
alias tk="task"
alias tlp="$(autosudo)netstat -tulpen"

which micro >/dev/null 2>&1 && alias mic="micro"
which miss >/dev/null 2>&1 && alias less="miss"

alias dml="$(autosudo) dmesg | less"
alias dmg=$(autosudo)' dmesg | grep -i "${@}"'

export LS_COLORS=${LS_COLORS}:"di=1;34":"*.txt=1;36":"*.md=0;93"
alias l="ls --color=auto -CF"
alias ll="ls --color=auto -lF"
alias la="ls --color=auto -AlF"

if [[ -n $(which ls-go) ]]; then
    alias l="ls-go -n"
    alias ll="ls-go -lnLS"
    alias la="ls-go -lanLS"
fi

if [[ -n "${HOME}" && -d "${HOME}" ]]; then
    cd "${HOME}"
fi
