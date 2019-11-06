#!/bin/zsh
# Soubor:  garbage_collection.zsh
# Datum:   06.11.2019 16:34
# Autor:   Marek Nožka, marek <@T> tlapicka <dot> net
# Licence: GNU/GPL 
# Úloha: 
############################################################


bridges=($(ip link show | grep -P 'br\d\d\d+:' | awk '{print $2}' | tr : ' '))
for br in $bridges; do
    brctl delbr $br
done

vxlans=($(ip link show | grep -P 'vxlan\d\d\d+:' | awk '{print $2}' | tr : ' '))
for vxlan in $vxlans; do
    ip link del $vxlan
done

taps=($(ip link show | grep -P 'tap\d\d\d+-.+:' | awk '{print $2}' | tr : ' '))
for tap in $taps; do
    tunctl -d $tap
done

