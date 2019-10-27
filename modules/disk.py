#!/usr/bin/env python
# coding: utf-8

'''
 * Author : Hutter Valentin
 * Date : 09.05.2019
 * Description : Hector agent monitoring
 * Help :
     - https://psutil.readthedocs.io/en/latest/#psutil.disk_io_counters
     - https://psutil.readthedocs.io/en/latest/#psutil.disk_usage
     - https://psutil.readthedocs.io/en/latest/#psutil.disk_partitions
'''

import psutil
import os
import sys
import time
sys.path.insert(0, '..') # to import helpers from parent folder
import helpers

class disk():

  def collect_overall_disk_usage(self):
    disk_usage = psutil.disk_usage('/')
    result = {
      'total': (helpers.bytes_to_mb(disk_usage.total)),
      'used': (helpers.bytes_to_mb(disk_usage.used)),
      'free': (helpers.bytes_to_mb(disk_usage.free)),
      'percent': disk_usage.percent,
    }
    
    return result

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

        # Bytes to mb
        diskresult['total'] = float("{0:.2f}".format(helpers.bytes_to_mb(diskresult['total'])))
        diskresult['used'] = float("{0:.2f}".format(helpers.bytes_to_mb(diskresult['used'])))
        diskresult['free'] = float("{0:.2f}".format(helpers.bytes_to_mb(diskresult['free'])))

        disksresult[partition.device] = diskresult # Build the results
      except:
          pass # Ignore exception on disk

    return disksresult

  def collect_io(self):
    results = {}
    disksdata_io = psutil.disk_io_counters(perdisk=True)

    for key, values in disksdata_io.items():
      disk_io = disksdata_io[key]
      results[key] = {
        'device': key,
        'read_count': disk_io.read_count,
        'write_count': disk_io.write_count,
        'read_mb': float("{0:.2f}".format(helpers.bytes_to_mb(disk_io.read_bytes))),
        'write_mb': float("{0:.2f}".format(helpers.bytes_to_mb(disk_io.write_bytes))),
        'read_time_sec': disk_io.read_time if float("{0:.2f}".format(helpers.ms_to_s(disk_io.read_time))) else None,
        'write_time_sec': disk_io.write_time if float("{0:.2f}".format(helpers.ms_to_s(disk_io.write_time))) else None,
      }
          
    return results
