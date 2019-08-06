#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:Dendi
'''try :from warframe_api.base import RestApi
except Exception as e:
    print('from warframe_api.base import RestApi')

    print(e)
'''
from warframe_api.base import RestApi
class qqqqa(RestApi):
		def __init__(self,domain='api.null00.com',port=80):
			RestApi.__init__(self,domain, port)
			self.storeId = None
			self.categoryName = None