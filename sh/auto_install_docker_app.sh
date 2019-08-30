#!/bin/bash
for i in ` ls /software/  ` ;do cd /software/$i && bash buildimage.sh && bash creatandrun.sh  ; done
