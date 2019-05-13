#!/usr/bin/env python
# coding: utf-8

'''
 * Author : Hutter Valentin
 * Date : 13.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
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
      '1min': "{0:.2f}".format(load[0]) if len(load) > 0 else None,
      '5min': "{0:.2f}".format(load[1]) if len(load) > 1 else None,
      '15min': "{0:.2f}".format(load[2]) if len(load) > 2 else None
    }

    return data