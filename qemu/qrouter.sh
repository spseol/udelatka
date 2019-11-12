#!/bin/zsh
# File:    qrouter.sh
# Date:    14.01.2015 09:14
# Author:  Marek Nožka, marek <@t> tlapicka <d.t> net
# Licence: GNU/GPL 
# Task:    Wrapper pro spuštění routru pro virtuální sítě a stroje
############################################################

snapshot='-snapshot'
graphic='-nographic'
amp='&'
for i in $@; do
    if [ $i = 'w' ]; then
        snapshot=''
        amp=''
    elif [ $i = 'g' ]; then
        graphic=''
        amp=''
    fi
done

nets=(100 101 102 103 104 105 106)

for vlan in $nets; do


    ip link show dev br$vlan &>/dev/null || {
        brctl addbr br$vlan
        ip link set up dev br$vlan

        ip link show dev vxlan$vlan &>/dev/null || {
            ip -6 link add vxlan$vlan type vxlan id $vlan dstport 4789 group ff05::100 dev br0 ttl 5
            ip link set up dev vxlan$vlan
        }
        brctl addif br$vlan vxlan$vlan

        tunctl -t tap$vlan
        ip link set up dev tap$vlan
        brctl addif br$vlan tap$vlan
    }

done


#-device e1000,netdev=n0,mac=56:52:EE:00:61:11 \ -netdev socket,id=n0,mcast=230.0.0.1:55544 \
#-device e1000,netdev=n1,mac=56:52:EE:01:61:11 \ -netdev socket,id=n1,mcast=230.0.0.1:54321 \
#-device e1000,netdev=n2,mac=56:52:EE:02:61:11 \ -netdev socket,id=n2,mcast=230.0.0.1:54322 \
#-device e1000,netdev=n3,mac=56:52:EE:03:61:11 \ -netdev socket,id=n3,mcast=230.0.0.1:54323 \
#-device e1000,netdev=n4,mac=56:52:EE:04:61:11 \ -netdev socket,id=n4,mcast=230.0.0.1:54324 \
#-device e1000,netdev=n5,mac=56:52:EE:05:61:11 \ -netdev socket,id=n5,mcast=230.0.0.1:54325 \
#-device e1000,netdev=n6,mac=56:52:EE:06:61:11 \ -netdev socket,id=n6,mcast=230.0.0.1:54326 \

for vlan in $nets; do
    mm=$(printf "%02x" $[$vlan - 100])
    netopt+=" -device e1000,netdev=n$vlan,mac=56:52:EE:$mm:61:11"
    netopt+=" -netdev tap,id=n$vlan,ifname=tap$vlan,script=no"
done
netopt+=" -device e1000,netdev=tap1,mac=56:52:EE:07:61:11"
netopt+=" -netdev tap,id=tap1,ifname=tap1,script=no"

cmd="kvm /storage/qrouter.img -m 182  $netopt $snapshot $graphic $amp"
print $cmd
eval $cmd
