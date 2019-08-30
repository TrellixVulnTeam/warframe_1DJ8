#!/bin/env python
import threading
import time
import os
loops=['192.168.11.203','192.168.11.204','192.168.11.205']

def work(ip):
        cmd='bash -x ./install.sh '+ip

        os.system(cmd)

def main():
        threads=[]
        nloops=range(len(loops))
        for i in loops:
                kscmd=""
                print kscmd
                os.system(kscmd)
                t=threading.Thread(target=work,args=(i,))
                t.start()
                time.sleep(40)
#               work(i)

if __name__=="__main__":
        main()
