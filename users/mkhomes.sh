#!/bin/zsh

#usernames="dub31562";
#usernames="marek";

for user in $@ ; do
    homedir="/home/${user}@spseol.cz"
    if ! [ -d $homedir ]; then
        mkdir -v --mode=711 $homedir
        cp -a /etc/skel/* $homedir
        cp -a /etc/skel/.[^.]* $homedir
        if [[ $user =~ "[a-z]{3}[0-9]{5}" ]]; then
            chown -R ${user}:zaci $homedir
        else
            chown -R ${user}:ucitele $homedir
        fi
    fi
done


exit 0;
