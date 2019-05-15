#!/usr/bin/env python
# coding: utf-8

'''
 * Author : Hutter Valentin
 * Date : 14.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
 * Help :
    - https://psutil.readthedocs.io/en/latest/#psutil.cpu_times_percent
    - https://psutil.readthedocs.io/en/latest/#psutil.cpu_percent
    - https://psutil.readthedocs.io/en/latest/#psutil.cpu_count
'''

import psutil
import sys
sys.path.insert(0, '..') # to import helpers from parent folder
import helpers

class cpu:

  def collect(self):
    cpus_times_percent = psutil.cpu_times_percent(interval=1, percpu=True)
    cpus_percent = psutil.cpu_percent(interval=1, percpu=True)
    data = {
      'processor_used_pct': psutil.cpu_percent(interval=1),
      'cpus_count': psutil.cpu_count(),
      'cpus': {}
    }
    
    # Retrieves the use in pourcent of each of the CPUs
    cpu_key = 0
    for cpu in cpus_times_percent:
      core = {}
      
      # Transformation of the tuple into a list by keeping the initial keys
      for key in cpu._fields:
        core[key] = getattr(cpu, key)

      # Adding cpu usage foreach core
      core['usage_pct'] = cpus_percent[cpu_key]

      cpu_key += 1
      data['cpus'][cpu_key] = core
  
    return data