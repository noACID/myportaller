#!/bin/bash

for I in `cat zones.override |grep zone|cut -f2 -d'"'|sed 's/.$//'`; do echo -n "${I}=/etc/powerdns/zones/db.override, ";done > 1.txt
for I in `cat zones.override_ |grep zone|grep -v ^#|cut -f2 -d'"'|sed 's/.$//'`; do echo -n "${I}=/etc/powerdns/zones/db.override, ";done > 2.txt