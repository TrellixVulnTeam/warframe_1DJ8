#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:Dendi
try: import httplib
except ImportError:
    import http.client as httplib
import urllib
import time
import hashlib
import json
import itertools
import mimetypes


import  pymysql
N_REST = "/world/ZHCN/oldMission"



class RestApi(object):
    # ===========================================================================
    # Rest api的基类
    # ===========================================================================

    def __init__(self, domain='gw.api.360buy.net', port=80):
        # =======================================================================
        # 初始化基类
        # Args @param domain: 请求的域名或者ip
        #      @param port: 请求的端口
        # =======================================================================
        self.__domain = domain
        self.__port = port
        self.__httpmethod = "GET"
        '''if (jd.getDefaultAppInfo()):
            self.__app_key = jd.getDefaultAppInfo().appkey
            self.__secret = jd.getDefaultAppInfo().secret'''
    def get_request_header(self):
        return {
            'Content-type': 'application/x-www-form-urlencoded',
            "Cache-Control": "no-cache",
            "Connection": "Keep-Alive",
            "Referer": "https: // ordis.null00.com / v1 /",
            "User - Agent": "Mozilla / 5.0(WindowsNT 6.1;Win64; x64) AppleWebKit / 537.36(KHTML, like Gecko) Chrome / 73.0.3683.103 Safari / 537.36",
        }

    def set_app_info(self, appinfo):
        # =======================================================================
        # 设置请求的app信息
        # @param appinfo: import jd
        #                 appinfo jd.appinfo(appkey,secret)
        # =======================================================================
        self.__app_key = appinfo.appkey
        self.__secret = appinfo.secret

    '''def getapiname(self):
        return ""'''

    def getMultipartParas(self):
        return [];

    def getTranslateParas(self):
        return {};

    def _check_requst(self):
        pass

    def getResponse(self, accessToken=None, timeout=30):
        # =======================================================================
        # 获取response结果
        # =======================================================================
        connection = httplib.HTTPConnection(self.__domain, self.__port, timeout)
       '''sys_parameters = {
            P_APPKEY: self.__app_key,
            P_VERSION: '2.0',
            P_API: self.getapiname(),
            P_TIMESTAMP: time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()),
        }'''
        '''if accessToken is not None:
            sys_parameters[P_ACCESS_TOKEN] = accessToken
        application_parameter = self.getApplicationParameters()
        sys_parameters[P_JSON_PARAM_KEY] = json.dumps(application_parameter, ensure_ascii=False, separators=(',', ':'))
        sys_parameters[P_SIGN] = sign(self.__secret, sys_parameters)'''
        connection.connect()
        url = "http://" + self.__domain + N_REST + "?" + "start=" + accessToken + "&pageSize=30"
        connection.request(self.__httpmethod, url)
        response = connection.getresponse();
        result = response.read()
        jsonobj = json.loads(result)
        return jsonobj

    '''def getApplicationParameters(self):
        application_parameter = {}
        for key, value in self.__dict__.iteritems():
            if not key.startswith("__") and not key in self.getMultipartParas() and not key.startswith(
                    "_RestApi__") and value is not None:
                if (key.startswith("_")):
                    application_parameter[key[1:]] = value
                else:
                    application_parameter[key] = value
        # 查询翻译字典来规避一些关键字属性
        translate_parameter = self.getTranslateParas()
        for key, value in application_parameter.iteritems():
            if key in translate_parameter:
                application_parameter[translate_parameter[key]] = application_parameter[key]
                del application_parameter[key]
        return application_parameter'''
