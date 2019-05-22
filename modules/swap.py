#!/usr/bin/env python3
# coding: utf-8

'''
 * Author : Hutter Valentin
 * Date : 09.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
 * Help :
    - https://psutil.readthedocs.io/en/latest/#psutil.swap_memory
'''

import psutil
import sys
sys.path.insert(0, '..') # to import helpers from parent folder
import helpers

class swap:

  def collect(self):
    data = {}
    swap = psutil.swap_memory()
    for key in swap._fields:
      data[key] = getattr(swap, key)

      if key != "percent":
        data[key] = float("{0:.2f}".format(helpers.bytes_to_mb(data[key]))) # Transform bytes to mb

    return data