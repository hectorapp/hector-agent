#!/usr/bin/env python

'''
 * Author : Hutter Valentin
 * Date : 08.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
'''

import psutil

class memory:

  def collect(self):
    data = {}
    memory = psutil.virtual_memory()
    for index in memory._fields:
      data[index] = getattr(memory, index)

      if index != "percent":
        data[index] = "{0:.2f}".format(data[index] / 1024.0 ** 2) # Transform bytes to mb

    return data