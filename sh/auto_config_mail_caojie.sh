#!/bin/bash
File=/etc/mail.rc
[ -f $File ] && cp $File $File.$(date +%F)
echo "set from=yj@caojie.top" >>$File
echo  "set smtp=smtp.mxhichina.com" >>$File
echo  "set smtp-auth-user=yj@caojie.top" >>$File
echo  "set smtp-auth-password=Asd12345" >>$File
echo  "set smtp-auth=login" >>$File
