#!/bin/bash
function md5sum_check(){
local Frist=$1
local Sencond=$2
local Mrist=$(/usr/bin/md5sum $1|awk '{print $1}')
local Srist=$(/usr/bin/md5sum $2|awk '{print $1}')
[ $Mrist == $Srist ] && exit 0 || exit 1
}
if [ $# -ne 2 ]
	then
	echo "$0 fiel_path1 file_path2"
	exit 1
fi
md5sum_check $1 $2
