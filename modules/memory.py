#!/usr/bin/env python
# coding: utf-8

'''
 * Author : Hutter Valentin
 * Date : 08.05.2019
 * Description : Hector agent monitoring
 * Help :
    - https://psutil.readthedocs.io/en/latest/#psutil.virtual_memory
'''

import psutil
import sys
sys.path.insert(0, '..') # to import helpers from parent folder
import helpers

class memory:

  def collect(self):
    data = {}
    memory = psutil.virtual_memory()
    for key in memory._fields:
      data[key] = getattr(memory, key)

      if key != "percent":
        data[key] = float("{0:.2f}".format(helpers.bytes_to_mb(data[key]))) # Transform bytes to mb

    return data
