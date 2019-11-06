#!/bin/zsh

if [[ $1 = 'students_from_pdc' ]]; then
    users=($(ldapsearch -x -h 172.24.1.1 -D "nozka@spseol.cz" -W \
                       -b "dc=spseol,dc=cz" \
                       -s sub "(cn=*)" cn mail sn \
            | grep -P '[a-z]{3}\d{5}@spseol.cz' \
            | sed -E 's/^.*([a-z]{3}[0-9]{5})@.*$/\1/g' \
            | tr '\n' ' '))
    
else
    users=($@)
fi

for user in $users ; do
    print "USER: $user"
    homedir="/home/${user}@spseol.cz"
    if [ -d $homedir ]; then
        cp -av /etc/skel/* $homedir
        cp -av /etc/skel/.[^.]* $homedir
        print "Nastavuji vlastnicví: $user pro $homedir"
        if [[ $user =~ "[a-z]{3}[0-9]{5}" ]]; then
            chown -R ${user}:zaci $homedir
        else
            chown -R ${user}:ucitele $homedir
        fi
    else
        print "ERR: $user nemá domovský adresář"
    fi
done

exit 0


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
