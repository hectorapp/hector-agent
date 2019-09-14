#!/usr/bin/env python
# coding: utf-8

'''
 * Author : Hutter Valentin
 * Date : 13.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
 * Help :
    - https://psutil.readthedocs.io/en/latest/#processes
      - https://psutil.readthedocs.io/en/latest/#psutil.process_iter
    - https://psutil.readthedocs.io/en/latest/#unicode
'''

import psutil
import sys
sys.path.insert(0, '..') # to import helpers from parent folder
import helpers

class process:
  DEFAULT_NB_OF_RETURNED_RESULTS = -35

  def collect(self):
    processes = []
    # Retrieves only processes that are running
    running_processes = [(process.info) for process in psutil.process_iter(attrs=[
      'pid', 'ppid', 'name', 'username', 'exe', 'cmdline',
      'cpu_percent', 'memory_percent', 'status'
    ]) if process.info['status'] == psutil.STATUS_RUNNING][self.DEFAULT_NB_OF_RETURNED_RESULTS:] #Limit to 30 processes
    
    for process in running_processes:
      try:
        process['cmdline'] = ' '.join(process['cmdline']).strip() #join args

        if 'cpu_percent' in process and process['cpu_percent'] is not None:
          process['cpu_percent'] = float("{0:.2f}".format(process['cpu_percent']))

        # Init process memory usage
        if 'memory_percent' in process and process['memory_percent'] is not None:
          # The RAM used by a process is recovered based on the total RAM available for the server where the agent is installed
          total_memory = psutil.virtual_memory().total
          process['memory_used_mb'] = float("{0:.2f}".format(helpers.bytes_to_mb(((total_memory / 100) * process['memory_percent']))))
          process['memory_percent'] = float("{0:.2f}".format(process['memory_percent']))
  
      except psutil.NoSuchProcess: # https://psutil.readthedocs.io/en/latest/#psutil.NoSuchProcess
        pass
      except psutil.AccessDenied: # https://psutil.readthedocs.io/en/latest/#psutil.AccessDenied
        pass
      except: #default exception
        pass 
      else:
        processes.append(process)

    return processes
