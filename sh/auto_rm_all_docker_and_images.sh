#!/bin/bash
for a in `docker ps -a|grep -v CONTAINER |awk -F"[- :]+" '{print $4}'`;
do
Docker_port=$a
Con_ID=$(docker ps -a  | grep $Docker_port |awk '{print $1}')
Ima_ID=$(docker images  |grep $Docker_port |awk '{print $3}')
docker stop $Con_ID &&\
docker rm $Con_ID &&\
docker rmi $Ima_ID
done
