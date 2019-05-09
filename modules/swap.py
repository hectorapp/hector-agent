#!/usr/bin/env python

'''
 * Author : Hutter Valentin
 * Date : 09.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
'''

import psutil

class swap:

  def collect(self):
    data = {}
    swap = psutil.swap_memory()
    for key in swap._fields:
      data[key] = getattr(swap, key)

      if key != "percent":
        data[key] = "{0:.2f}".format(data[key] / 1024.0 ** 2) # Transform bytes to mb

    return data