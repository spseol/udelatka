#!/bin/bash

usernames="$usernames $(ypcat passwd | egrep 'students'| egrep -v ecdl |awk -F : '{print $1}' | sort )";
#usernames="dub31562";
#usernames="marek";

echo "#############################################"
echo " vytvářím nové"
for user in $usernames ; do
    homedir="/home/students/$user"
    if ! [ -d $homedir ]; then
        mkdir -v --mode=711 $homedir
        cp -Rd /etc/skel/* /etc/skel/.[^.]* $homedir
        ln -s /home/hroch/$user /home/students/$user/hroch
        #mv /home/loni/students/$user $homedir/loni
        chown -R $user:student $homedir
    fi
done

echo "#############################################"
echo " smažu staré"
passwd=$(ypcat passwd)

for user in $(ls /home/students/); do
    if ! echo $passwd | egrep $user &>/dev/null; then
        #echo "mv  /home/students/$user /home/old-homes/"
        #mv /home/students/$user /home/old-homes/
        echo "rm -Rf  /home/students/$user"
        rm -Rf /home/students/$user
    fi
done


exit 0;
