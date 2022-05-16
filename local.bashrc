# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

cat_help_table() {
    awk -v var="#__ALIAS__HELP__TABLE" 'BEGIN { ORS=" " };$0 ~ var {print NR}' ~/.bashrc
}

alias_help() {
    start=$(awk '{print $2}' <<< $(cat_help_table) )
    end=$(awk '{print $3}' <<< $(cat_help_table) )
    ((start=$start+2))
    ((end=$end-2))
    sed -n -e "$start,$end p" -e "$end q" ~/.bashrc
}

docker_exec_bash() {
	docker exec -it "$1" bash
}

docker_run_name() {
    # runs containers by image id that provided by awk that matches images by name($1)
    # and pattern that image name should has as substring
	docker run $(awk -v include="$1" '$1 ~ include {print $3}' <<< $(docker images))
}

# Opens last created container's bash
docker_exec_bash_latest() {
	cid=$(docker ps -ql)
	docker_exec_bash "$cid"
}

# Opens bash in container which name contains provided parameter
docker_exec_bash_by_name() {
    cid="$(awk '{print $1}' <<<  $(docker ps | grep -E "*$1*"))"
	docker_exec_bash "$cid"
}

docker_remove_images() {
    docker rmi $(docker images -a -q)
}

docker_remove_containers() {
    docker stop $(docker ps -a -q)
    docker rm $(docker ps -a -q)
}

docker_clear() {
    docker_remove_containers
    docker_remove_images
}

#__ALIAS__HELP__TABLE
#--------------------------------------------------------------------------------------------------------
alias s="1>/dev/null"                           #   runs command without stdin                          |
                                                #                                                       |
alias hh=alias_help                             #   shows this table in the terminal                    |
                                                #                                                       |
alias dps="docker ps"                           #                                                       |
                                                #                                                       |
alias drun="docker run"                         #                                                       |
                                                #                                                       |
alias dc=docker-compose                         #                                                       |
                                                #                                                       |
alias dcu="docker-compose up"                   #                                                       |
                                                #                                                       |
alias dcud="docker-compose up -d"               #                                                       |
                                                #                                                       |
alias dcd="docker-compose down"                 #                                                       |
                                                #                                                       |
alias dcb="docker-compose build"                #                                                       |
                                                #                                                       |
alias dcex="docker exec -it"                    #                                                       |
                                                #                                                       |
alias dcexl=docker_exec_bash_latest             #   opens bash in container that was created last       |
                                                #                                                       |
alias dexn=docker_exec_bash_by_name             #   opens bash in container's name include parameter    |
      # dexn ~[NAME]                            #   requires 1 parameter - container included name      |
alias dcuxl="dcud && dcexl"                     #   runs container(s) and opens in last bash            |
                                                #                                                       |
alias dcuxn="dcud && dcexn"                     #   runs container(s) and opens bash in named as args   |
      # duxn ~[NAME]                            #                                                       |
alias dcbu="dcb && dcu"                         #   build container(s) and ups them                     |
                                                #                                                       |
alias dcbud="dcb && dcud"                       #   build container(s) and ups them          [silently] |
                                                #                                                       |
alias dcdbu="dcd && dcbu"                       #   downs container(s) then build and ups them          |
                                                #                                                       |
alias dcdbud="dcd && dcdud"                     #   downs container(s) then build and ups them[silently]|
                                                #                                                       |
alias drm="docker rm"                           #   removes items                                       |
                                                #                                                       |
alias drmimg="docker rmi"                       #   removes items                                       |
                                                #                                                       |
alias dcp="docker system prune"                 #   clears images, container(s), volumes                |
                                                #                                                       |
alias di="docker images -a"                     #   shows all container's images                        |
                                                #                                                       |
alias drmi=docker_remove_images                 #   removes all unused images                           |
                                                #                                                       |
alias drmc=docker_remove_containers             #   removes all unused containers                       |
                                                #                                                       |
alias dclear=docker_clear                       #   removes all unused containers and images            |
#--------------------------------------------------------------------------------------------------------
#__ALIAS__HELP__TABLE__END__

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
