#!/bin/bash
#by : Dendy
#date 2017-10-19 11:25:11
#QQ : 2257752828
File=/etc/mail.rc
[ -f $File ] && cp $File{,.$(date +%F)}
echo "set from=yj@24k.com" >>$File
echo "set smtp="smtps://smtp.exmail.qq.com:465"" >>$File
echo "set smtp-auth-user=yj@24k.com" >>$File
echo "set smtp-auth-password=Asd1234566" >>$File
echo "set smtp-auth=login" >>$File
echo "set nss-config-dir=/etc/pki/nssdb" >>$File
echo "set ssl-verify=ignore" >>$File