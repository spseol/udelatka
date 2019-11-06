setopt ALL_EXPORT

EDITOR='mcedit'
PAGER='less'
LESS='-ir'
PYTHONIOENCODING=UTF8

# černá	        0;30	tmavě šedá	    1;30
# červená	    0;31	světle červená	1;31
# zelená	    0;32	světle zelená	1;32
# hnědá	        0;33	žlutá	        1;33
# modrá	        0;34	světle modrá	1;34
# purpurová	    0;35	světle purpurová1;35
# azurová	    0;36	světle azurová	1;36
# světle šedá	0;37	bílá	        1;37
#GREP_COLORS='1;35'
GREP_COLORS='ms=01;33:mc=01;33:sl=:cx=:fn=35:ln=32:bn=32:se=36'

unsetopt ALL_EXPORT

############################################################
#    The following lines were added by compinstall
#############################################################
zstyle ':completion:*' completer _oldlist _complete _match _prefix _list _approximate
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z} m:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'
zstyle ':completion:*' match-original both
zstyle ':completion:*' menu select=1 _complete _ignored _approximate
#zstyle :compinstall filename '~/.zshrc'
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST
zstyle ':completion:*' squeeze-slashes false

# End of lines added by compinstall
#############################################################

#############################################################
#   automatické doplňování
#############################################################
autoload -U compinit # -z
compinit
# automatické doplňování má barvičky
zmodload -i zsh/complist
eval $(dircolors -b ~/.dir_colors) 
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"


setopt nohup
#LC_MESSAGES=C

# History
HISTFILE=~/.histfile
HISTSIZE=9999
SAVEHIST=9999
setopt append_history 
setopt inc_append_history   # historie se uloží vždy předtím, než se cmd spustí
                            # takže nová relace ji bude mít k dispozici
setopt histbeep
setopt incappendhistory
#setopt sharehistory  
#setopt EXTENDED_HISTORY		# puts timestamps in the history
setopt histignorespace        # pokud začnu příkaz mezerou neuloží se do historie
#setopt HISTIGNOREALLDUPS      # příkaz je v historii jen jednou
setopt histignoredups         #  vymaže duplicitní příkazy, které jdou zasebou
setopt histexpiredupsfirst    # vymaže všechny duplicity pokud je historie plná
setopt histfindnodups         # duplicity v historii hledá jen jednou
setopt histreduceblanks       # vymaže nic neznamenající mezery v příkazu
#setopt histallowclobber       # v historii přepíše > na >| 



#############################################################
# Chování příkazového řádku, vstup výstup
#############################################################
#
#bindkey -v
# chová se jako Emacs
bindkey -e
# ale když stisku Esc začnese chovat jako VI
#bindkey '^[' vi-cmd-mode
bindkey ' ' magic-space    #mezerník rozbaluje odkazy na historii || also do history expansion on space
bindkey '^Z' complete-word # complete on tab, leave expansion to _expand

#bindkey '^p' history-search-backward  # hledání řádku se stejným prvním slovem
#bindkey '^n' history-search-forward
bindkey '^p' history-beginning-search-backward  # hledání řádku, který se shoduje od začátku do pozice kurzoru
bindkey '^n' history-beginning-search-forward
#
# Vi style:
autoload -U edit-command-line  
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

### Korektury při překlepu
setopt nocorrect 			# příkaz
#setopt correctall 		# celý řádek
#setopt globdots		# * se chová jako * a .*
#
# bezpečné přesměrování výstupu
#setopt noclobber  # >> > >! >| >>! 
#setopt clobber  # >> > >! >| >>! 
# pokročílá expanze žolíkových znaků
setopt extendedglob # **/*.txt
#
setopt beep notify #un
# cd
setopt autocd # pokud napíšu jen cestu pouužije se automaticky cd
#CDPATH=".:~:~/Documents:~/Documents/SPSe"
CDPATH=".:~:~/Documents/SPSe:~/Documents/VOS"

#############################################################
###      Completion
#############################################################
setopt autonamedirs alwaystoend nomenucomplete
setopt COMPLETE_ALIASES AUTO_NAME_DIRS AUTO_PARAM_SLASH AUTO_REMOVE_SLASH 
setopt automenu autolist
setopt autoparamkeys listambiguous listbeep listpacked listtypes
setopt magic_equal_subst    # aby se dopnňovalo i za =

#############################################################
#           Doplňování příkazu kill                         #
#############################################################
## command for process lists, the local web server details and host completion
## on processes completion complete all user processes
#zstyle ':completion:*:processes' command 'ps -au$USER'
#
### add colors to processes for kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
#
#zstyle ':completion:*:processes' command 'ps ax -o pid,s,nice,stime,args | sed "/ps/d"'
if [ $USER = root ]; then
    zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,%cpu,cmd'
else
    zstyle ':completion:*:*:kill:*:processes' command 'ps fx -o pid,user,%cpu,cmd'
fi
zstyle ':completion:*:processes-names' command 'ps axho command' 

#############################################################
#                 Prompt                                    #
#############################################################
autoload -U promptinit
promptinit; 

if [ `whoami` = root ]; then
#        prompt adam2 cyan red red forground;
    ZSHcol=red
else
#        prompt adam2 cyan yellow green forground;
    ZSHcol=green
fi

if [ $SSH_CLIENT ]; then 
    ZSHcol2=red
else 
    ZSHcol2=green
fi

#datum a čas
ZSHd="%b%F{yellow}%D{%a %e.%b %Y %T}"
#tty
ZSHt="%b%F{green}%l"
RPROMPT="%B<%F{black}%!%F{default}|$ZSHd%F{default}|$ZSHt"
##########################################
#
#začátek
ZSHo="%B%F{cyan}.%2c"
ZSHo="%B%F{cyan}.%B%F{black}%?%b%F{cyan}%b%F{cyan}%(?.\<:-).\>:-\()"
# user@host
ZSHh="%B%F{forground}|%B%F{black}(%b%F{$ZSHcol}%n%B%F{black}@%b%F{$ZSHcol2}%m%B%F{black})"
# druhý řádek
ZSHz="%B%F{cyan}\`-%b%F{cyan}-%B%F{white}%B%F{forground}%(\!.##.>) %b%f%k"
ZSHk="%B%F{black}-."

##########################################
title () {
    if [ -z $terminaltitle ] && [ $TERM != "linux" ]; then
#        aplikace=$(ps -a|egrep ${TTY#/dev/}|egrep -v 'ps$|egrep|tail|awk'|awk '{print $4}'|tail -1)
#        echo -ne "\033]0;${USER}@`hostname -s`:`pwd | sed s%$HOME%\~%`[$aplikace]\007"
        echo -ne "\033]0;${USER}@`hostname -s`:`pwd | sed s%$HOME%\~%`\007"
    fi
}

precmd () {
    ZSHlen=${#${(%):-.%?.:....%n@%m...%~...}}
    if (( $ZSHlen < $COLUMNS )); then
        ZSHesc='%~'
    else 
        ZSHesc='^/%2c'
        ZSHlen=${#${(%):-.%?.:....%n@%m..../%2c...}}
        if (( $ZSHlen > $COLUMNS )); then
            ZSHesc='^/%1c'
        fi
    fi
    for ((i=0; i< $[ $COLUMNS - $ZSHlen ] ; i++)); do
        local ZSHline="-$ZSHline"
    done
    ZSHline="%b%F{cyan}$ZSHline"
#   #pracovní adresář
    ZSHw="%b%F{cyan}-%B%F{black}(%B%F{yellow}$ZSHesc%B%F{black})"
#  Python VIRTUAL_ENV
    if [ $VIRTUAL_ENV ]; then
        ZSH_VENV=\($(basename $VIRTUAL_ENV)\)
        ZSHz="%B%F{cyan}\`-${ZSH_VENV}%b%F{cyan}-%B%F{white}%B%F{forground}%(\!.##.>) %b%f%k"
    else
        ZSHz="%B%F{cyan}\`-%b%F{cyan}-%B%F{white}%B%F{forground}%(\!.##.>) %b%f%k"
    fi
    PROMPT=$(print $ZSHo$ZSHh$ZSHw$ZSHline$k\\n$ZSHz)
#   #MC
    if [ $ISMC ] || [ $MC_SID ]; then
#        prompt walters $ZSHcol 
        unset RPROMPT
    fi
    title 
}

##########################################
preexec () {
    if [[ "$TERM" == "screen" ]]; then
        local CMD=${1[(wr)^(*=*|sudo|-*)]}
        echo -n "\ek$CMD\e\\"
    fi
}



#############################################################
#              připojí aliasy a funkce 
#############################################################
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi
if [ -f ~/.aliases.local ]; then
    . ~/.aliases.local
fi


#############################################################
#     Autoload zsh modules when they are referenced
#############################################################
zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof

#############################################################

eval $(dircolors -b ~/.dir_colors) 
