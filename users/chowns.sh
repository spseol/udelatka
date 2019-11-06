#!/bin/zsh

#usernames="dub31562";
#usernames="marek";

for user in $@ ; do
    homedir="/home/${user}@spseol.cz"
    if [ -d $homedir ]; then
        chmod 711 $homedir
        if [[ $user =~ "[a-z]{3}[0-9]{5}" ]]; then
            echo ::chown -R ${user}:zaci $homedir
            chown -R ${user}:zaci $homedir
        else
            echo ::chown -R ${user}:ucitele $homedir
            chown -R ${user}:ucitele $homedir
        fi
    fi
done


exit 0;
