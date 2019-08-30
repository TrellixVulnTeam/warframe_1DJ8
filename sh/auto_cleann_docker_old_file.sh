#!/bin/bash
#清理已删除的docker容器文件
docker_dir=/var/lib/docker/devicemapper/mnt
cd $docker_dir
du -sh * > /tmp/docker-file.txt
del_file=$(cat /tmp/docker-file.txt |grep 4.0K|awk -F" " '{print $2}')
rm -rf $del_file

