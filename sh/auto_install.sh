#!/bin/bash
#cobbler 安装好以后并且导入镜像后
cd  /scripts
bash auto_2_ks.sh &&\
bash ip_2_hosts.sh &&\
bash view_fw_info.sh mkdir -p /scripts 
bash view_fw_info.sh mkdir /scripts/old
bash view_fw_info.sh mkdir /scripts/info
bash view_fw_info.sh mv /scripts/\* /scripts/old/
bash fenfa_fw_file.sh &&\
bash view_fw_info.sh bash /scripts/install_vm.sh
