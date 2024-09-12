cgrn="\033[1;92m"
cred="\033[1;91m"
cyel="\033[0;93m"
cnon="\033[0m"

autosudo() {
  if [[ "$(id -u)" != "0" && -n "$(which sudo)" ]]; then echo "sudo "; fi
}

show_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

update_bashrc() {
  curl --output ${HOME}/.bashrc \
    https://raw.githubusercontent.com/triole/ghwfe/master/bashrc/default.sh
}

tailf() {
  if [[ -d "${1}" ]]; then
    tail -F $(find ${1} -type f -mindepth 1 -maxdepth 1)
  else
    tail -F "${1}"
  fi
}

get_exit_status() {
  es=${?}
  if [ ${es} -ne 0 ]; then
    echo -e "${cred}${es}${cnon} "
  fi
}

ps1_prefix="\u@$(hostname) ${cyel}\w${cnon}"
ps1_suffix="${cgrn}\$ ${cnon}"
if [[ $(id -u) -eq 0 ]]; then
  ps1_suffix="${cred}# ${cnon} "
fi
export PS1="\$(get_exit_status)${ps1_prefix} \$(show_git_branch) ${ps1_suffix}"

alias ..="cd .."
alias addgrp="usermod -a -G"
alias addusr="useradd"
alias cl="clear"
alias dml="$(autosudo) dmesg | less"
alias dmg=$(autosudo)' dmesg | grep -i "${@}"'
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
alias psa='_psa(){ if [[ -n "${1}" ]]; then ps faux | grep "${1}" | grep -v "grep.*${1}"; else ps faux; fi };_psa'
alias tk="task"
alias tlp="$(autosudo)netstat -tulpen"

which micro >/dev/null 2>&1 && alias mic="micro"
which miss >/dev/null 2>&1 && alias less="miss"

export LS_COLORS=${LS_COLORS}:"di=1;34":"*.txt=1;36":"*.md=0;93"
alias l="ls --color=auto -CF"
alias ll="ls --color=auto -lF"
alias la="ls --color=auto -AlF"

which mic >/dev/null 2>&1 && {
  export EDITOR="mic"
}

which ls-go >/dev/null 2>&1 && {
  alias l="ls-go -n"
  alias ll="ls-go -lnLS"
  alias la="ls-go -lanLS"
}

if [[ -n "${HOME}" && -d "${HOME}" ]]; then
  cd "${HOME}"
fi
