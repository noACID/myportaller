#!/bin/bash

#for I in `cat zones.override |grep zone|cut -f2 -d'"'|sed 's/.$//'`; do echo -n "${I}=/etc/powerdns/zones/db.override, ";done > 1.txt
#for I in `cat zones.override_ |grep zone|grep -v ^#|cut -f2 -d'"'|sed 's/.$//'`; do echo -n "${I}=/etc/powerdns/zones/db.override, ";done > 2.txt

crdmn(){
echo  "server:
local-zone: \"${1}\" redirect
local-data: \"${1} 10800 SOA ns1.${1}. root 1 3600 1200 604800 10800\"
local-data: \"${1} 10800 NS ns1.${1}.\"
local-data: \"${1} A 162.210.192.19\""
}

for I in `cat zones.override_ |grep zone|grep -v ^#|cut -f2 -d'"'|sed 's/.$//'`; do crdmn "${I}";done > 3.txt