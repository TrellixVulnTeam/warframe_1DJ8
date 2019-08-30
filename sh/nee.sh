#!/bin/bash
LU='┌'
RU='┐'
LD='└'
RD='┘'
UU='─'
UD='│'
a=' '
START=4
LINE=`stty size|awk '{print $1}'`
COLUMN=`stty size|awk '{print $2}'`
JX=` echo "$LINE*0.8"|bc |awk -F'.' '{print $1}'`




#ethn=$1
#if [ $ethn != '' ];then
#while true
#	do
#		RX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
#		TX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')
#		sleep 1
#		RX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
#		TX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')
#		clear
#		echo -e "\t RX `date +%k:%M:%S` TX"
#		RX=$((${RX_next}-${RX_pre}))
#		TX=$((${TX_next}-${TX_pre}))
#		if [[ $RX -lt 1024 ]];then
#			RX="${RX}B/s"
#		elif [[ $RX -gt 1048576 ]];then
#			RX=$(echo $RX | awk '{print $1/1048576 "MB/s"}')
#		else
#			RX=$(echo $RX | awk '{print $1/1024 "KB/s"}')
#		fi
#		if [[ $TX -lt 1024 ]];then
#			TX="${TX}B/s"
#		elif [[ $TX -gt 1048576 ]];then
#			TX=$(echo $TX | awk '{print $1/1048576 "MB/s"}')
#		else
#			TX=$(echo $TX | awk '{print $1/1024 "KB/s"}')
#		fi
#		echo -e "$ethn \t $RX   $TX  $a"
##echo "$LINE  ,$COLUMN"
if [ $START -lt $LINE ];then
for i in $(seq $START $LINE);do
   c="$a"                
  for b in $(seq $START  $COLUMN);do
    if [ $i == $START ];then
      if [ $b == $START ];then
        a=$LU
      elif [ $b == $COLUMN ] ;then
        a=$RU
      else
        a=$UU
      fi 
    elif [ $i == $LINE ];then
      if [ $b == $START ];then
        a=$LD
      elif [ $b == $COLUMN ] ;then
        a=$RD
      else
        a=$UU
      fi
    elif [[ $i == $JX ]]; then
    	 if [ $b == $START ];then
      		a=$UD
          elif [ $b == $COLUMN ] ;then
         	 a=$UD
          else
         	 a='.'
        fi
    else
      if [ $b == $START ];then
        a=$UD
      elif [ $b == $COLUMN ] ;then
        a=$UD
      else
        a=$c  
fi
    fi
    echo -n "$a" ;
    a="$c";
  done;
  echo
  a=' '
done
else
echo 'too large'
fi
#done
#else 
#	echo 'no input'
#fi
