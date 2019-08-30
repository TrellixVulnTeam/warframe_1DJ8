#!/bin/bash
for i in `docker ps -a  |grep -v CONTAINER |awk '{print $1}'` ; do docker restart $i ; done
