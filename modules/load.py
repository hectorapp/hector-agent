#!/usr/bin/env python
# coding: utf-8

'''
 * Author : Hutter Valentin
 * Date : 13.05.2019
 * Description : Hector agent monitoring
 * Help :
    - https://psutil.readthedocs.io/en/latest/#psutil.getloadavg
'''

import psutil
import sys
sys.path.insert(0, '..') # to import helpers from parent folder
import helpers

class load:

  def collect(self):
    load = psutil.getloadavg()
    data = {
      '1min': float("{0:.2f}".format(load[0])),
      '5min': float("{0:.2f}".format(load[1])),
      '15min': float("{0:.2f}".format(load[2]))
    }

    return data
