#!/bin/bash
function Send_Sms(){
    local Number=18566662527
    local Time=`date +%Y.%m.%d_%H:%M:%S`
    local Info="$1"
    local Url="http://ws.montnets.com:7903/MWGate/wmgw.asmx/MongateCsSpSendSmsNew"
    /usr/bin/curl -d "userId=J21731&password=116123&pszMobis=${Number}&pszMsg=${Info}&iMobiCount=1&pszSubPort=\*"   ${Url}  >>/dev/null
}
 Send_Sms "$1"
