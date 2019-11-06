#!/bin/zsh
# Soubor:  ipfire.zsh
# Datum:   16.02.2015 15:23
# Autor:   Marek Nožka, marek <@T> tlapicka <dot> net
# Licence: GNU/GPL 
# Úloha:   Spustí ipfire + windows počítač do GREEN sítě
############################################################
xhost +local:root

image="/var/tmp/ipfire-${USER}.img"

# MACkonec jsou poslední 4 číslice z IP adresy. 172.16.6.103 --> 61:03
MACkonec=$(ip a s | egrep '172\.16' | perl -e '$vstup=<>; $vstup=~/(\d+\.\d+.\d+.\d+)/; ($vstup=$1)=~s/\.//g; $vstup=~/(..)(..)$/;  print "$1:$2\n";')
# síťový PORT je 5000 + (poslední číslo v IP)
PORT=$(ip a s | egrep '172\.16' | perl -e '$vstup=<>; $vstup=~/\d+\.\d+.\d+.(\d+)/; ($vstup=$1); $port=$1+5000; print "$port\n";')

MAC1="52:54:00:a1:$MACkonec"
MAC2="52:54:00:a2:$MACkonec"
MACW="52:54:00:b1:$MACkonec"

netoptF="-net nic,vlan=99,macaddr=${MAC1},model=rtl8139"
netoptF+=" -net socket,vlan=99,mcast=230.0.0.1:55544"
netoptF+=" -net nic,vlan=1,macaddr=${MAC2},model=rtl8139"
netoptF+=" -net socket,vlan=1,mcast=230.0.0.1:$PORT"

netoptW="-net nic,vlan=1,macaddr=${MACW},model=rtl8139"
netoptW+=" -net socket,vlan=1,mcast=230.0.0.1:$PORT"

# Instalace
if [[ $0 =~ "install" ]]; then
    if ! [ -e $image ]; then
        sudo qemu-img create -f qcow2 $image 4G
    else
        echo Soubor $image již existuje. 
        echo Pro opakovanou instalaci jej nejprve smažte.
        exit 1
    fi
    discF="-cdrom /home/qemu/ipfire.iso -hda $image -boot d"

# Spuštění po instalaci
else
    discF="$image"
    discW="/var/tmp/winxp.img"
    echo sudo kvm -m 512 $netoptW $discW -snapshot
    eval sudo kvm -m 512 $netoptW $discW -snapshot &
fi

echo sudo kvm -m 182 $netoptF $discF
eval sudo kvm -m 182 $netoptF $discF  &
