#!/bin/bash
daemon python /server/jumpserver-master/manage.py runserver 127.0.0.1:8080  &>> /var/log/jumpserver.log 2>&1
