#!/bin/bash
 _server=$1
docker stop `docker ps -a |grep -i ${_server}|awk '{print $1}'`
echo  "${_server} docker stop !! " 
