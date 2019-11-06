#!/bin/bash

if [ -z $1 ]; then
    echo "Nezadal jsi žádné parametry!"
    echo
    echo "$0 l main 2 w 2 "
    echo " lan == tap"
    echo "   0 == main == top"
    echo "1"
    echo "2"
    echo "3"
    echo "4"
    echo "5"
    echo "..."
    echo ".."
    echo "."
    exit 1
fi

jmeno=$(basename $0)
if [  $jmeno = "startqemu.local" ]; then
    adr="/storage"
elif [  $jmeno = "startqemu.net" ]; then
    adr="/home/qemu"
else
    echo $0
    echo "CHYBA. Končím."
    exit 1
fi

xhost +local:root >/dev/null

# každý virtuální stroj musí mít jiné MAC adresy, 
# proto se poslední byte generuje z IP adresy hostitelského PC
# a jedna část adersy je náhodná (viz proměnná $nahoda).
zIP=$(ip a s | egrep '172\.24'| perl -e '$vstup=<>; $vstup=~/(\d+\.\d+.\d+.\d+)/; ($vstup=$1)=~s/\.//g; $vstup=~/(..)(..)$/;  print "$1:$2\n";')
echo id = \"$zIP\";
echo


# začne sestavování příkazu
zacatek() {
    netopt='';
    cmd="$1"
}

# ukončí sestavování příkazu
konec() {
    cmd="$cmd $netopt -snapshot" 
    echo -ne "$cmd\n\n"
    $cmd &
}

volbaOs() {
    if [ -z $PrvniParametr ]; then
        zacatek "$1"
        PrvniParametr="1"
    else
        konec
        zacatek "$1"
    fi
}

i=1
for opt in $@; do
    case "$opt" in
        [wW]) 
            volbaOs "sudo kvm $adr/winxp.img -m 512"
            ;;
        [lL]) 
            volbaOs "sudo kvm $adr/qemumachine.img -m 182"
            ;;
        [mM]) 
            volbaOs "sudo kvm $adr/mikrotik.img -m 64"
            ;;
        [Tt][Aa][Pp]|[Ll][Aa][Nn])
            MAC="52:54:00:00:$zIP"
            #netopt="$netopt -net nic,vlan=0,macaddr=$MAC,model=rtl8139 -net tap,vlan=0,ifname=tap0,script=no"
            netopt="-device rtl8139,netdev=n00,mac=$MAC -netdev tap,id=n00,ifname=tap0,script=no"
            ;;
        [0Oo]|[Tt][Oo][Pp]|[Mm][Aa][Ii][Nn])
            PORT=55544
            xI=$(printf "%.2X\n" $i) # $i v Hexa
            nahoda=$(printf "%.2X\n" $[ $RANDOM % 256 ]) # náhodné číslo
            MAC="52:$nahoda:dd:$xI:$zIP"
            #netopt="$netopt -net nic,vlan=99,macaddr=$MAC,model=rtl8139 -net socket,vlan=99,mcast=230.0.0.1:$PORT"
            netopt="$netopt -device rtl8139,netdev=n99,mac=$MAC -netdev socket,id=n99,mcast=230.0.0.1:$PORT"
            i=$[ $i + 1 ]
            ;;
        [1-9]|[1-9][0-9])
            PORT=$[ 54320 + $opt ]
            xI=$(printf "%.2X\n" $i) # $i v Hexa
            xopt=$(printf "%.2X\n" $opt) # $opt v Hexa
            nahoda=$(printf "%.2X\n" $[ $RANDOM % 256 ]) # náhodné číslo
#           MAC="52:54:$xopt:$xI:$zIP"
            MAC="52:$nahoda:$xopt:$xI:$zIP"
            netopt="$netopt -device rtl8139,netdev=n$i,mac=$MAC -netdev socket,id=n$i,mcast=230.0.0.1:$PORT"
            i=$[ $i + 1 ]
            ;;
    esac
done

konec



