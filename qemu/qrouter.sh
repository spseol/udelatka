#!/bin/bash
# File:    qrouter.sh
# Date:    14.01.2015 09:14
# Author:  Marek Nožka, marek <@t> tlapicka <d.t> net
# Licence: GNU/GPL 
# Task:    Wrapper pro spuštění routru pro virtuální sítě a stroje
############################################################
    #-net nic,vlan=0,macaddr=56:52:EE:00:61:11,model=rtl8139 \
    #-net socket,vlan=0,mcast=230.0.0.1:55544 \
    #-net nic,vlan=1,macaddr=56:52:EE:01:61:11,model=rtl8139 \
    #-net socket,vlan=1,mcast=230.0.0.1:54321 \
    #-net nic,vlan=2,macaddr=56:52:EE:02:61:11,model=rtl8139 \
    #-net socket,vlan=2,mcast=230.0.0.1:54322 \
    #-net nic,vlan=3,macaddr=56:52:EE:03:61:11,model=rtl8139 \
    #-net socket,vlan=3,mcast=230.0.0.1:54323 \
    #-net nic,vlan=4,macaddr=56:52:EE:04:61:11,model=rtl8139 \
    #-net socket,vlan=4,mcast=230.0.0.1:54324 \
    #-net nic,vlan=5,macaddr=56:52:EE:05:61:11,model=rtl8139 \
    #-net socket,vlan=5,mcast=230.0.0.1:54325 \
    #-net nic,vlan=6,macaddr=56:52:EE:06:61:11,model=rtl8139 \
    #-net socket,vlan=6,mcast=230.0.0.1:54326 \
    #-net nic,vlan=99,macaddr=56:52:EE:99:61:11,model=rtl8139 \
    #-net tap,vlan=99,ifname=tap1,script=no \

snapshot='-snapshot'
graphic='-nographic'
for i in $@; do
    if [ $i = 'w' ]; then
        snapshot=''
    elif [ $i = 'g' ]; then
        graphic=''
    fi
done

sudo kvm /storage/qrouter.img -m 182  \
    -device e1000,netdev=n0,mac=56:52:EE:00:61:11 \
    -netdev socket,id=n0,mcast=230.0.0.1:55544 \
    -device e1000,netdev=n1,mac=56:52:EE:01:61:11 \
    -netdev socket,id=n1,mcast=230.0.0.1:54321 \
    -device e1000,netdev=n2,mac=56:52:EE:02:61:11 \
    -netdev socket,id=n2,mcast=230.0.0.1:54322 \
    -device e1000,netdev=n3,mac=56:52:EE:03:61:11 \
    -netdev socket,id=n3,mcast=230.0.0.1:54323 \
    -device e1000,netdev=n4,mac=56:52:EE:04:61:11 \
    -netdev socket,id=n4,mcast=230.0.0.1:54324 \
    -device e1000,netdev=n5,mac=56:52:EE:05:61:11 \
    -netdev socket,id=n5,mcast=230.0.0.1:54325 \
    -device e1000,netdev=n6,mac=56:52:EE:06:61:11 \
    -netdev socket,id=n6,mcast=230.0.0.1:54326 \
    -device e1000,netdev=n99,mac=56:52:EE:06:61:11 \
    -netdev tap,id=n99,ifname=tap1,script=no \
    $snapshot $graphic 
