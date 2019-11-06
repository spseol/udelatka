#!/bin/zsh
# Soubor:  mkpsqlaccount.zsh
# Datum:   11.11.2014 11:13
# Autor:   Marek Nožka, marek <@T> tlapicka <dot> net
############################################################

help() {
    echo "$0 [-c] user1 user2 ..."
    echo 
    echo "-c  WITH CREATEDB CREATEUSER"
    exit 0
    echo
}

if [ $1 = '-h' ]; then
    help
fi

if [ $1 = '-c' ]; then
    shift 1
    NO=''
else
    NO='NO'
fi

if [ -z $1 ]; then
    help
fi

for user in $@; do
    pass=$(pwgen 8 1)
    
    cd ~postgres
    cat >sql.psql <<EOF 
CREATE USER $user WITH
    ${NO}CREATEDB
    ${NO}CREATEROLE
    UNENCRYPTED PASSWORD '$pass';
CREATE DATABASE $user WITH 
    OWNER = $user
    TEMPLATE = template0 
    ENCODING 'UTF8' 
    LC_COLLATE 'cs_CZ.UTF-8'
    LC_CTYPE 'cs_CZ.UTF-8';
REVOKE ALL ON DATABASE $user FROM PUBLIC;

EOF
    echo $user
    echo
    sudo -u postgres psql <sql.psql && \
        mutt -s postgreSQL -a sql.psql -- ${user}@spseol.cz <<EOF
Dobrý den.

Dovolujeme si Vám oznámit, že vám byl vytvořen databázový účet 
$user a databáze $user v PostgreSQL. Vaše heslo je $pass

K databázy se můžete připojit pouze ze školní sítě na adrese 
https://hroch.spseol.cz/adminer/

nebo z příkazové řádky 

$ psql -h hroch.spseol.cz $user $user

nebo jen 

$ psql -h hroch.spseol.cz

Zajímavý editor ER diagramů, který generuje SQL kód najdete na adrese
https://editor.ponyorm.com/


Marek Nožka

P.S.: V příloze si dovoluji vám zaslat SQL kód, který vám vytvořil 
      uživatelský účet a databázy.
EOF

done
