#!/bin/bash
# Soubor:  startkvm.sh
# Datum:   24.11.2010 11:36
# Autor:   Marek Nožka, marek <@T> tlapicka <dot> net
# Licence: GNU/GPL 
# Úloha:   spustí kvm s virtuálními počítači v testovacích sítích.
############################################################

#######           HELP           ##########
# pokud existuje parametr -h vytiskne help
for param in $@; do
    if [ $param == "-h" ] || [ $param == "--help" ]; then
        cat <<EOF
$(basename $0) <[-zr|-zw] [l-<host>|w-<host> [tap] n1 n2 ... ] 0>   

l  spustí linoxového hosta /storage/kvm/l-<host>.img
          v sítích nX nebo připijeného k tap0

w  spustí windows hosta /storage/kvm/w-<host>.img
          v sítích nX nebo připijeného k tap0


EOF
        ls -l --color=auto /storage/kvm/{l-*,w-*}
        exit 0;
    fi
done

############################################################
sysctl net/ipv4/ip_forward=1
iptables -t nat -A POSTROUTING -s 192.168.240.0/20 -j MASQUERADE
############################################################

i=1
for opt in $@; do
    case "$opt" in
        w-*) 
            mem="512"
            name=${opt#w-}
            image="/storage/kvm/${opt}.img"
        ;;
        l-*) 
            mem="182"
            name=${opt#l-}
            image="/storage/kvm/${opt}.img"
        ;;
        tap)
            if ! [ "$tapnet" ]; then 
                MAC="52:54:ab:cd:ee:00"
                netopt="$netopt -net nic,vlan=0,macaddr=$MAC,model=rtl8139 -net tap,vlan=0,ifname=tap0,script=no"
                name="$name tap"
                tapnet="uz je to nastaveno"
            fi
        ;;
        [1-9]|[1-9][0-9])
            PORT=$[ 54320 + $opt ]
            xI=$(printf "%.2X\n" $i) # $i v Hexa
            MAC="52:54:ab:cd:ef:$xI"
            netopt="$netopt -net nic,vlan=$i,macaddr=$MAC,model=rtl8139 -net socket,vlan=$i,mcast=230.0.0.1:$PORT"
            name="$name:$opt"
            i=$[ $i + 1 ]
        ;;
        cdrom=*)
            netopt="$netopt  -cdrom ${opt#cdrom=} -boot d"
        ;;
        [rw]) 
            if [ $opt = r ]; then
                cmd="sudo kvm $image -m $mem $netopt -name $name:$opt -k en-us -snapshot"
            else 
                cmd="sudo kvm $image -m $mem $netopt -name $name:$opt -k en-us"
            fi
            netopt='';
            echo -ne "$cmd\n\n"
            $cmd &
            sleep 1;
        ;;
        -z[rw])
            if [ $opt = "-zr" ]; then 
                snapshot="-snapshot"
            else 
                snapshot=""
            fi
            echo -ne "kvm zirafa $snapshot\n\n"
            kvm /storage/kvm/l-zirafa.img -m 182 -name zirafa:tap:1:2:3:4:5 \
                -net nic,vlan=0,macaddr=52:54:ab:cd:ee:00 -net tap,vlan=0,ifname=tap0,script=no \
                -net nic,vlan=1,macaddr=52:54:ab:cd:ee:01 -net socket,vlan=1,mcast=230.0.0.1:54321 \
                -net nic,vlan=2,macaddr=52:54:ab:cd:ee:02 -net socket,vlan=2,mcast=230.0.0.1:54322 \
                -net nic,vlan=3,macaddr=52:54:ab:cd:ee:03 -net socket,vlan=3,mcast=230.0.0.1:54323 \
                -net nic,vlan=4,macaddr=52:54:ab:cd:ee:04 -net socket,vlan=4,mcast=230.0.0.1:54324 \
                -net nic,vlan=5,macaddr=52:54:ab:cd:ee:05 -net socket,vlan=5,mcast=230.0.0.1:54325 \
                -k en-us $snapshot &
                sleep 1;
        ;;
    esac
done

echo "Po stisknutí enter se vypne MASQUERADE"
read;
############################################################
iptables -t nat -D POSTROUTING -s 192.168.240.0/20 -j MASQUERADE
sysctl net/ipv4/ip_forward=0
############################################################
