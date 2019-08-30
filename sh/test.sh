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
UX=` echo "$LINE*0.1"|bc |awk -F'.' '{print $1+4}'`

DATE=`date +%W%N`
lock_dir=/tmp/$DATE
lock_file=/tmp/caojie.top.lock
sort_file1=/tmp/caojie.top.sort_file1
sort_file2=/tmp/caojie.top.sort_file2
RXZ_pre_rile=/tmp/caojie.top.RXZ_file
if test -f  $lock_file  ;then
  orm=`cat $lock_file`
  rm -fr /tmp/$orm
fi
if test -f  $sort_file1  ;then
  rm -fr $sort_file1
fi
if test -f  $sort_file2  ;then
  rm -fr $sort_file2
fi
if test -f  $RXZ_pre_rile  ;then
  rm -fr $RXZ_pre_rile
fi
echo 0 > $RXZ_pre_rile
echo "$DATE" > $lock_file
mkdir $lock_dir
for f in $(seq $UX $JX);
do
  echo ' ' > $lock_dir/f$f;
  echo $f >> $sort_file1
done
cat $sort_file1|sort  -rn > $sort_file2
ethn=eth0
#####################################################################ethn=$1
#if [ $ethn != '' ];then
while true
do
  RX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
  TX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')
  sleep 1
  RX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
  TX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')
  clear
  echo -e "\t RX `date +%k:%M:%S` TX"
  RX=$(($RX_next-$RX_pre))
  RXZ=$RX
  RXZ_pre=`cat $RXZ_pre_rile`

  echo "$RX" > $lock_dir/f$UX

  TX=$(($TX_next-$TX_pre))
  TXZ=$TX
  if [ $RX -lt 1024 ];then
    RX="${RX}B/s"
  elif [[ $RX -gt 1048576 ]];then
    RX=$(echo $RX | awk '{print $1/1048576 "MB/s"}')
  else
    RX=$(echo $RX | awk '{print $1/1024 "KB/s"}')
  fi
  if [ $TX -lt 1024 ];then
    TX="${TX}B/s"
  elif [[ $TX -gt 1048576 ]];then
    TX=$(echo $TX | awk '{print $1/1048576 "MB/s"}')
  else
    TX=$(echo $TX | awk '{print $1/1024 "KB/s"}')
  fi
  echo -e "$ethn \t $RX   $TX  $a"
  if test $RXZ -ge $RXZ_pre  ;then

    echo $RXZ > $RXZ_pre_rile
    RXZ_dis=$RX
  fi
  len=`awk  -v string="$RXZ_dis" 'BEGIN { print length(string)'}`
  ##echo "$LINE  ,$COLUMN"
  if test $START -lt $LINE ;then
    #for i in $(seq $START $LINE);do
    #   c="$a"
    #  for b in $(seq $START  $COLUMN);do
    #    if [ $i == $START ];then
    #      if [ $b == $START ];then
    #        a=$LU
    #      elif [ $b == $COLUMN ] ;then
    #        a=$RU
    #      else
    #        a=$UU
    #      fi
    #    elif [ $i == $LINE ];then
    #      if [ $b == $START ];then
    #        a=$LD
    #      elif [ $b == $COLUMN ] ;then
    #        a=$RD
    #      else
    #        a=$UU
    #      fi
    #    elif [[ $i == $JX ]]; then
    #       if [ $b == $START ];then
    #          a=$UD
    #          elif [ $b == $COLUMN ] ;then
    #           a=$UD
    #          else
    #           a='.'
    #        fi
    #    else
    #      if [ $b == $START ];then
    #        a=$UD
    #      elif [ $b == $COLUMN ] ;then
    #        a=$UD
    #      else
    #        a=$c
    #fi
    #    fi
    #    echo -n "$a" ;
    #    a="$c";
    #  done;
    #  echo
    #  a=' '
    #done
    for i in $(seq $START $LINE);do
      c="$a"
      if test $i == $START ;then
        for b in $(seq $START  $COLUMN);do
          if test $b == $START ;then
            a=$LU
          elif [ $b == $COLUMN ] ;then
            a=$RU
          else
            a=$UU
          fi
          echo -n "$a" ;
          a="$c";
        done
        echo
      elif [ $i == $LINE ];then
        for b in $(seq $START  $COLUMN);do
          if test $b == $START ;then
            a=$LD
          elif [ $b == $COLUMN ] ;then
            a=$RD
          else
            a=$UU
          fi
          echo -n "$a" ;
          a="$c";
        done
        echo
      elif [[ $i == $(($UX-1)) ]]; then
        for b in $(seq $START  $(($COLUMN-$len+1)));do
          if test $b == $START ;then
            a=$UD
          elif [ $b == $(($START+1)) ];then
            a=$RXZ_dis
          elif [ $b == $(($COLUMN-$len+1)) ] ;then
            a=$UD
          else
            a=' '
          fi
          echo -n "$a" ;
          a="$c";
        done
        echo
      elif [[ $i == $UX ]]; then
        for b in $(seq $START  $(($COLUMN-$len+1)));do
          if test $b == $START ;then
            a=$UD
          elif [ $b == $(($START+1)) ];then
            a=$RXZ_dis
          elif [ $b == $(($COLUMN-$len+1)) ] ;then
            a=$UD
          else
            a='.'
          fi
          echo -n "$a" ;
          a="$c";
        done
        echo
      elif [ $i -gt $UX -a  $i -lt $JX ]; then
        for b in $(seq $START  $COLUMN);do
          if test $b == $START ;then
            a=$UD
          elif [ $b == $COLUMN ] ;then
            a=$UD
          elif [ $b == xx ];then
            a='x'
          else
            a=' '
          fi
          echo -n "$a" ;
          a="$c";
        done
        echo
      elif [[ $i == $JX ]]; then
        for b in $(seq $START  $COLUMN);do
          if test $b == $START ;then
            a=$UD
          elif [ $b == $COLUMN ] ;then
            a=$UD
          else
            a='.'
          fi
          echo -n "$a" ;
          a="$c";
        done
        echo
      else
      #
        #for g  in $(seq $(($)));do
          for b in $(seq $START  $COLUMN);do
            if test $b == $START ;then
              a=$UD
            elif [ $b == $COLUMN ] ;then
              a=$UD
            else
              a=$c
            fi
            echo -n "$a" ;
            a="$c";
          done
          echo
        fi
      done;


    else
      echo 'too large'
    fi
    #done
    #else
    # echo 'no input'
    #fi
    for e in `cat $sort_file2`;
    do
      if test -f $lock_dir/f$(($e-1)) ;then
        cat $lock_dir/f$(($e-1)) > $lock_dir/f$e;
      fi
    done
  done

