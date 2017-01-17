#!/bin/zsh

for cislo in $(seq 1 25); do
    ip route del 172.30.$cislo.0/28 via 172.30.0.$cislo
done
