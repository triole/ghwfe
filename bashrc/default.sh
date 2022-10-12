show_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\u@\h \033[0;93m\w\033[0m \$(show_git_branch) \\033[1;92m\$\\033[0m "
if [[ "$(whoami)" == "root" ]]; then
    export PS1="\u@\h \033[0;93m\w\033[0m \$(show_git_branch) \\033[1;31m# \\033[0m "
fi

alias ..="cd .."
alias cl="clear"
alias env="env | sort"
alias gip="git pull"
alias grep="grep --color"
alias lsblk="lsblk -o name,maj:min,ro,rm,type,size,mountpoint,label,uuid,pttype,parttypename,type,vendor,model,serial"
alias mic="micro"
alias p="python"
alias pm="python manage.py"
alias pkl="pkill -9"
alias psa='function _psa(){ if [[ -n "${1}" ]]; then ps faux | grep "${1}" | grep -v "grep.*${1}"; else ps faux; fi };_psa'
alias tailf="tail -F"
alias tk="task"
alias tlp="netstat -tulpen"
alias tlps="sudo netstat -tulpen"

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
