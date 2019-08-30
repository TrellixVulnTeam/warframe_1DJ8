#!/bin/bash
_server=$1
docker restart `docker ps -a |grep -i ${_server}|awk '{print $1}'`
echo  "${_server} docker start !! " 
