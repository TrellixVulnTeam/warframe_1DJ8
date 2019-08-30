#!/bin/bash
# 举个例子 /tmp/20171222-154047-2a8a/paymentV2-web-0.0.1-SNAPSHOT.war
LOCK_FILE="deploy.lock"
LOCK_DIR="/var/lock/deploy"
LOG_DIR="/var/log"
LOG_FILE="deploy.log"
# Lock
function shell_lock(){
	check_folder ${LOCK_DIR}
    touch ${LOCK_DIR}/${LOCK_FILE}
}
function  shell_unlock(){
    rm -f ${LOCK_DIR}/${LOCK_FILE}
}
function check_folder(){
    local folder=$1
    if [ ! -d $folder ] ;then 
        mkdir -p $folder
        Msg "$folder had been make"
    else
        log_info "$folder Already exists "
    fi
}
function log(){
    datetime=`date +"%F %H:%M:%S"`
    message=$1
    if [ -z "$2" ]
    then
        loglevel="INFO"
    else
        loglevel=$2
    fi
    outdir="${LOG_DIR}"
    if [ ! -d "$outdir" ]; then
        mkdir "$outdir"
    fi
    logname="${LOG_FILE}"
    echo "$datetime [$0] [$(pwd)][$loglevel] :: $message" | tee -a "$outdir/$logname"
}
function log_error(){
        log "$1" "ERROR"
}
function log_info(){
        log "$1" "INFO"
}
function Msg(){
    if [ $? -eq 0 ];then
    log_info "$1"
    else
    log_error "$1"
    fi
}
function base_info(){
 _dir_name=$(dirname  ${_name_path})
 if [  "${_dir_name}" == "." ];then
 		echo "${_war_name}  _dir_name ${_dir_name}  not exists !!"
 		shell_unlock
 		exit 1
 fi
 #  /tmp/20171222-154047-2a8a
 _war_name=$(basename ${_name_path})
case "${_war_name}" in 
 goldwallet-mobile.war|ctop-quartz-0.0.2-SNAPSHOT.war|crowdFunding-web.war|anti-admin.war|anti-merchant.war|crowdFunding-admin.war|goldBusinessV2-admin.war|goldBusinessV2-web.war|goldReserves-web.war|goldSaveV2-web.war|goldBusinessV2-mobile.war|goldReserves-batch.war|goldSaveV2-admin.war|crowdFunding-admin.war|logistics-web-0.0.1-SNAPSHOT.war|quotation-web.war|goldwallet-pc.war|goldwallet-web.war|goldShopV2-pc.war|goldShopV2-pad.war|goldShopV2-mobile.war|ctop-admin.war|ctop-merchant.war|getcode-wx.war|ctop-sms.war|paymentV2-web-0.0.1-SNAPSHOT.war|goldwallet-dubbo.war|goldReserves-batch.war|goldReserves-web.war|ctop-test.war)
 ;;
 *)
 echo "${_war_name}    not can be use  !!"
 		shell_unlock
 		exit 1
 ;;
esac
 _test_war_name=${_war_name}.$(date +%F%N)
}
#  paymentV2-web-0.0.1-SNAPSHOT.war
function choose_war_ip(){
 _server_group_ip1="$(cat $0|grep ^##|grep ${_war_name}|awk '{print $2}')"
 zero_dollar  "${_server_group_ip1}"  "_server_group_ip1"
 _server_group_ip2="$(cat $0|grep ^##|grep ${_war_name}|awk '{print $3}')"
 zero_dollar  "${_server_group_ip2}"  "_server_group_ip2"
 _war_path_pro="$(cat $0|grep ^##|grep ${_war_name}|awk '{print $4}')"
 zero_dollar  "${_war_path_pro}"  "_war_path_pro"
 _war_path_docker="$(cat $0|grep ^##|grep ${_war_name}|awk '{print $5}')"
 zero_dollar  "${_war_path_docker}"  "_war_path_docker"
}
# 判断是否为空
# zero_dollar  "${_server_group_ip2}"  "_server_group_ip2"
function zero_dollar(){
	local _zero=$1
	local _dollar=$2
	if [ -z ${_zero} ];then
		echo "${_war_name}  ${_dollar}  not exists !!"
		shell_unlock
		exit 1
	fi
}
# mkdir_fenfa 192.168.6.113  /tmp/20171223-163348-41b4
function mkdir_fenfa(){
	local host=$1
	local _dir=$2
	ssh $host "mkdir -p /tmp/${_dir}"
}
function check_fenf_file(){
	local host=$1
	local _dir=$2
	ssh $host "ls /tmp/${_dir}" >>${LOG_DIR}/${LOG_FILE}
}
# fenfa_package 192.168.6.113  /tmp/20171223-163348-41b4/paymentV2-web-0.0.1-SNAPSHOT.war
function fenfa_package(){
	local file=$1
	local ip=$2
	local path=$3
	scp  $file  ${ip}:/tmp/${path}/
}
function fenfa_war(){
	local s_dir=$1
	local ip=$2
	local d_dir=$3
	mkdir_fenfa $ip  ${d_dir}
	fenfa_package   ${s_dir}  $ip  ${d_dir}  >>${LOG_DIR}/${LOG_FILE}
	#fenfa_package  ${_dir_name}/${_war_name}  $i ${_dir_name}/
	check_fenf_file $ip  ${d_dir}
}
function  update_code(){
	local Host=$1
	_Pro_dir="/home/hjkj/apps/${_war_path_pro}.pro"
	_War_dir="/home/hjkj/apps/${_war_path_pro}"
	_Bak_dir1="/home/hjkj/apps/${_war_path_pro}.bak.1"
	_Bak_dir2="/home/hjkj/apps/${_war_path_pro}.bak.2"
	Maven_dir="/home/hjkj/apps/"
	ssh ${Host} "mkdir -p ${_Pro_dir}"
	ssh ${Host} "mkdir -p ${_Bak_dir2}"
	ssh ${Host} "rm -rf  ${_Bak_dir2} "	
	ssh ${Host} "mkdir -p ${_Bak_dir1}"
	ssh ${Host}	"mv ${_Bak_dir1} ${_Bak_dir2}"
	ssh ${Host} "mv /tmp/${_test_war_name}/${_war_name}  ${_Pro_dir}/"
	ssh ${Host} "cd ${_Pro_dir} && unzip ${_war_name}" >>/dev/null 
	ssh ${Host} "docker stop   ${_war_path_docker}"
	ssh ${Host} "mkdir -p ${_War_dir} "
	ssh ${Host} "mv  ${_War_dir}  ${_Bak_dir1}"
	ssh ${Host} "mv  ${_Pro_dir}  ${_War_dir}"
	ssh ${Host} "docker restart   ${_war_path_docker}"
	sleep 3
	ssh ${Host} "docker ps -a "
}
function  roll_code(){
	local Host=$1
	_Pro_dir="/home/hjkj/apps/${_war_path_pro}.roll"
	_War_dir="/home/hjkj/apps/${_war_path_pro}"
	_Bak_dir1="/home/hjkj/apps/${_war_path_pro}.bak.1"
	_Bak_dir2="/home/hjkj/apps/${_war_path_pro}.bak.2"
	Maven_dir="/home/hjkj/apps/"
	ssh ${Host} "docker stop   ${_war_path_docker}"
	ssh ${Host} "mkdir -p ${_Pro_dir}"
	ssh ${Host} "rm -rf  ${_Pro_dir} "
	ssh ${Host} "mkdir -p ${_Bak_dir1}"
	ssh ${Host} "mkdir -p ${_War_dir} "
	ssh ${Host} "mv  ${_War_dir}   ${_Pro_dir}"
	ssh ${Host} "mv  ${_Bak_dir1}  ${_War_dir}"
	ssh ${Host} "mv  ${_Bak_dir2}  ${_Bak_dir1}"
	ssh ${Host} "docker restart   ${_war_path_docker}"
	sleep 3
	ssh ${Host} "docker ps -a "
}
function Update_code(){
	choose_war_ip
	fenfa_war  ${_dir_name}/${_war_name}  ${_server_group_ip1} ${_test_war_name}
	update_code ${_server_group_ip1}
if [  ${_server_group_ip1} != ${_server_group_ip2} ] ;then
	fenfa_war  ${_dir_name}/${_war_name}  ${_server_group_ip2} ${_test_war_name}
	update_code ${_server_group_ip2}
fi
}
function Roll_code(){
	choose_war_ip
	roll_code ${_server_group_ip1}
	roll_code ${_server_group_ip2}
}
function main(){
	if [ -f "${LOCK_DIR}/${LOCK_FILE}" ];then
    	log_error "Deploy is Running "
    	exit 1
  	fi
  	if [ $# -ne 2 ]
    then
    	Msg "Usage like : `basename $0`  /tmp/example/example.war  {update | config | roll_back} " 
    	shell_unlock
    	exit 1
    fi
	_name_path=$1
	if [ "X${_name_path}" == "X" ];then
		Msg "Usage like : `basename $0`  /tmp/example/example.war  {update | config | roll_back} " 
		shell_unlock
		exit 1
	fi
	base_info
	action=$2
	case "$action" in
		update|config)
		Update_code
		;;
		roll_back)
		Roll_code
		;;
		3)
		main_1
		main_2
		;;
		*)
		Msg "Usage like : `basename $0`  /tmp/example/example.war  {update | config | roll_back} " 
		shell_unlock
		exit 1
		;;
	esac
	shell_unlock
}
main $1 $2
##############################项目分布
## 192.168.6.113 192.168.6.123 goldwallet-mobile goldwallet-mobile-38330 		goldwallet-mobile.war
## 192.168.6.113 192.168.6.123 goldwallet-pc     goldwallet-pc-38340  			goldwallet-pc.war
## 192.168.6.113 192.168.6.123 goldwallet-web    goldwallet-web-38360 			goldwallet-web.war
## 192.168.6.113 192.168.6.123 eshop-pc 	     eshop-pc-38260  				goldShopV2-pc.war
## 192.168.6.113 192.168.6.123 eshop-pad 	 	 eshop-pad-38120  				goldShopV2-pad.war
## 192.168.6.113 192.168.6.123 eshop-mobile  	 eshop-mobile-38220 			goldShopV2-mobile.war
## 192.168.6.113 192.168.6.113 anti-admin	anti-admin-28230		anti-admin.war
## 192.168.6.113 192.168.6.113 anti-merchant 	anti-merchant-28240		anti-merchant.war
##############################
## 192.168.6.115 192.168.6.125 ctop-admin 	  	 ctop-admin-28110  				ctop-admin.war
## 192.168.6.115 192.168.6.125 ctop-merchant  	 ctop-merchant-28120 			ctop-merchant.war
## 192.168.6.115 192.168.6.125 getcode-wx 	  	 getcode-wx-28130  				getcode-wx.war
## 192.168.6.115 192.168.6.125 ctop-quartz 	  	 ctop-quartz-28280  				ctop-quartz-0.0.2-SNAPSHOT.war
##############################
## 192.168.6.116 192.168.6.126 quotation-web  	 quotation-web-15008			quotation-web.war
## 192.168.6.116 192.168.6.126 logistics-web   	 logistics-web-38850			logistics-web-0.0.1-SNAPSHOT.war
## 192.168.6.116 192.168.6.126 ctop-log  	   	 ctop-log-28130
## 192.168.6.116 192.168.6.126 ctop-sms  	   	 ctop-sms-38230   				ctop-sms.war
## 192.168.6.116 192.168.6.126 ctop-email 	   	 ctop-email-38240
##############################
## 192.168.6.118 192.168.6.127 paymentV2-web 		paymentv2-web-38110  		paymentV2-web-0.0.1-SNAPSHOT.war
## 192.168.6.118 192.168.6.127 goldwallet-dubbo 	goldwallet-dubbo-38250 		goldwallet-dubbo.war
## 192.168.6.118 192.168.6.127 goldsavev2-admin 	goldsavev2-admin-28330 		goldSaveV2-admin.war
## 192.168.6.118 192.168.6.127 finance-batch 		finance-batch-28220   		goldReserves-batch.war
## 192.168.6.118 192.168.6.127 crowdfunding-admin 	crowdfunding-admin-38650 	crowdFunding-admin.war
## 192.168.6.118 192.168.6.127 business-admin 		business-admin-28320 		goldBusinessV2-admin.war
##############################
## 192.168.6.133 192.168.6.143 goldsavev2-web 		goldsavev2-web-38210 		goldSaveV2-web.war
## 192.168.6.133 192.168.6.143 finance-mobile 		finance-mobile-38310  		goldReserves-web.war
## 192.168.6.133 192.168.6.143 crowdfunding-web 	crowdfunding-web-38750 		crowdFunding-web.war
## 192.168.6.133 192.168.6.143 business-web 		business-web-28210 		goldBusinessV2-web.war
## 192.168.6.133 192.168.6.143 business-mobile 		business-mobile-38350 		goldBusinessV2-mobile.war
###############################
## 192.168.6.138 192.168.6.138 ctop-test	 		ctop-test-66666				ctop-test.war
