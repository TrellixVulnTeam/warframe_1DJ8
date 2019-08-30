#!/bin/bash
head  -n 2 /etc/hosts >/scripts/hosts
cat /scripts/all_client_ip.txt | grep -v ^# |awk   '{print $3"  "$8" "$2}'  >>/scripts/hosts
cat /scripts/all_fw_ip.txt | awk '{print $1"  "$2}' >>/scripts/hosts
