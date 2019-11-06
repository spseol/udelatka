#!/bin/bash
# Soubor:  qemu-img.sh
# Datum:   18.10.2012 00:22
# Autor:   Marek Nožka, marek <@T> tlapicka <dot> net
# Licence: GNU/GPL 
# Úloha:   vytvoří image disku
############################################################
FILE=/var/tmp/${USER}.img

if [ -f $FILE ]; then
    echo -ne "Pokud jsi si jistý, že chceš smazat svou starou instalaci,\n"
    echo -ne "napiš prosím 'ano' > "
    read ano
    if [ $ano != 'ano' ]; then
        echo -ne "\n> Nic nedělám a končím!\n\n"
        exit 1
    else
        echo -ne "\n> Přepisuji!\n\n"
    fi
fi

sudo qemu-img create -f qcow2 $FILE 7G
