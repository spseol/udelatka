#!/bin/zsh

if [ -z $1 ]; then
    cat <<EOF
Nezadal jsi žádné parametry!

$0 l main 2 w 2 
 lan == tap
 0 == main == top
EOF
    exit 1
fi

jmeno=$(basename $0)
adr="/storage/iso-distro"

if [[  $jmeno =~ net ]]; then
    adr="/home/qemu"
fi

xhost +local:root >/dev/null

# každý virtuální stroj musí mít jiné MAC adresy, 
# proto se poslední byte generuje z IP adresy hostitelského PC
# a jedna část adersy je náhodná (viz proměnná $nahoda).
zIP=$(ip a s | egrep '10\.189'| perl -e '$vstup=<>; $vstup=~/(\d+\.\d+.\d+.\d+)/; ($vstup=$1)=~s/\.//g; $vstup=~/(..)(..)$/;  print "$1:$2\n";')
print "from IP id = \"$zIP\"\n";


createBridge() {
    vlan100=$1
    tap=$2

    ip link show dev br$vlan100 &>/dev/null || 
        brctl addbr br$vlan100

    ip link show dev vxlan$vlan100 &>/dev/null || 
        ip -6 link add vxlan$vlan100 type vxlan id $vlan100 dstport 4789 group ff05::100 dev eth0 ttl 5

    brctl show | grep vxlan$vlan100 &>/dev/null ||
        brctl addif br$vlan100 vxlan$vlan100

    tunctl -t $tap
    brctl addif br$vlan100 $tap

}


mkNetopt() {
    vlan=$1
    vlan100=$[100 + $vlan]
    temp=$(mktemp -u XXXXXXX)
    tap="tap$vlan100-$temp"
    id="v$vlan.i${i}.${temp}"

    createBridge $vlan100 $tap

    xI=$(printf "%.2X\n" $i) # $i v Hexa
    xopt=$(printf "%.2X\n" $opt) # $opt v Hexa
    nahoda=$(printf "%.2X\n" $[ $RANDOM % 256 ]) # náhodné číslo
    MAC="52:$nahoda:$xopt:$xI:$zIP"

    netopt="$netopt -device rtl8139,netdev=$id,mac=$MAC"
    netopt="$netopt -netdev tap,id=$id,ifname=$tap,script=no"
    i=$[ $i + 1 ]
}


# začne sestavování příkazu
zacatek() {
    netopt='';
    cmd="$1"
}

# ukončí sestavování příkazu
konec() {
    cmd="$cmd $netopt -snapshot" 
    #cmd="$cmd $netopt" 
    echo -ne "$cmd\n\n"
    eval $cmd &
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
            volbaOs "kvm $adr/winxp.img -m 512"
            ;;
        [lL]) 
            volbaOs "kvm $adr/devuan.img -m 182"
            ;;
        [mM]) 
            volbaOs "kvm $adr/mikrotik.img -m 64"
            ;;
        [Tt][Aa][Pp]|[Ll][Aa][Nn])
            MAC="52:54:00:00:$zIP"
            netopt="-device rtl8139,netdev=n00,mac=$MAC -netdev tap,id=n00,ifname=tap0,script=no"
            ;;

        [0Oo]|[Tt][Oo][Pp]|[Mm][Aa][Ii][Nn])
            mkNetopt 0
            ;;

        [1-9]|[1-9][0-9])
            mkNetopt $opt
            ;;
    esac
done

konec



