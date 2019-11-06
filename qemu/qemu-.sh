#!/bin/zsh
# Soubor:  qemu-install.sh
# Datum:   18.10.2012 00:26
# Autor:   Marek Nožka, marek <@T> tlapicka <dot> net
# Licence: GNU/GPL 
# Úloha:   Instaluje OS z image nebo ho spustí
############################################################

xhost +local:root

zIP=$(ip a s | egrep '172\.24' | perl -e '$vstup=<>; $vstup=~/(\d+\.\d+.\d+.\d+)/; ($vstup=$1)=~s/\.//g; $vstup=~/(..)(..)$/;  print "$1:$2\n";')

MAC="52:54:00:00:$zIP"

#netopt="-net nic,vlan=99,macaddr=$MAC,model=rtl8139 -net socket,vlan=99,mcast=230.0.0.1:55544"
#netopt="-device e1000,netdev=n00,mac=$MAC -netdev tap,id=n00,ifname=tap0,script=no"
netopt="-device e1000,netdev=n99,mac=$MAC -netdev socket,id=n99,mcast=230.0.0.1:55544"

if [[ $0 =~ "install" ]]; then
    disc="-cdrom /home/qemu/install.iso -hda /var/tmp/${USER}.img -boot d"
else
    disc="/var/tmp/${USER}.img"
fi

if [[ $1 =~ "-n" ]]; then
    NO="-nographic"
else
    NO=""
fi
echo eval sudo kvm -m 312 $netopt $disc $NO &
eval sudo kvm -m 312 $netopt $disc $NO &
