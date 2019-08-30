#!/bin/bash
Docker_port=$1
Con_ID=$(docker ps -a  | grep $Docker_port |awk '{print $1}')
Ima_ID=$(docker images  |grep $Docker_port |awk '{print $3}')
docker stop $Con_ID &&\
docker rm $Con_ID &&\
docker rmi $Ima_ID

