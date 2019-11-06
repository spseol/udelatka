# ~/.zshrc

# the default umask is set in /etc/login.defs
umask 022

if [ -d /home/bin ] ; then
    PATH=/home/bin:"${PATH}"
    export PATH
fi
# set PATH so it includes user's private bin if it exists
if [ -d ~/bin ] ; then
    PATH=~/bin:"${PATH}"
    export PATH
fi
# do the same with MANPATH
if [ -d ~/man ]; then
    MANPATH=~/man${MANPATH:-:}
    export MANPATH
fi
