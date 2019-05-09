#!/usr/bin/env python

'''
 * Author : Hutter Valentin
 * Date : 09.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
'''

import psutil
import os

class disk:

  def collect_partitions(self):
    disksresult = {}
    disk_partitions = psutil.disk_partitions(all=False)

    for partition in disk_partitions:
      # Help for this part - Official example : https://github.com/giampaolo/psutil/blob/master/scripts/disk_usage.py
      if os.name == 'nt':
        if 'cdrom' in partition.opts or partition.fstype == '':
          # skip cd-rom drives with no disk in it; they may raise
          # ENOENT, pop-up a Windows GUI error for a non-ready
          # partition or just hang.
          continue
      try:
        disk_usage = psutil.disk_usage(partition.mountpoint)
        diskresult = {}

        for key in disk_usage._fields:
          diskresult[key] = getattr(disk_usage, key)
          diskresult['mountpoint'] = partition.mountpoint
          diskresult['fstype'] = partition.fstype

        disksresult[partition.device] = diskresult # Build the results
      except:
          pass # Ignore exception on disk

    return disksresult

  def collect_io(self):
    results = {}

    diskdata = psutil.disk_io_counters(perdisk=True)
    
    for device, values in diskdata.items():
      device_stats = {}
      for key_value in values._fields:
        device_stats[key_value] = getattr(values, key_value)
      
      results[device] = device_stats
          
    return results