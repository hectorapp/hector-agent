#!/usr/bin/env python
# coding: utf-8

'''
 * Author : Hutter Valentin
 * Date : 14.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
 * Help :
    - https://docs.python.org/fr/3.6/library/subprocess.html
'''

import psutil
import sys
from subprocess import Popen, PIPE
sys.path.insert(0, '..') # to import helpers from parent folder
import helpers

class ping:

  def collect(self):
    data = {}
    servers = {
      'us': 'google.com',
      'ch': 'valentinhutter.ch'
    }

    for region, host in servers.items():
      try:
        ping = Popen('ping -c 2 -W 5 ' + host, shell=True, stdout=PIPE)
        output = ping.communicate()[0]

        if output:
          if "Destination host unreachable" in output.decode('utf-8') or "Request timeout" in output.decode('utf-8'):
            data[region] = {
              'host': host,
              'sucessful': False,
            }
          else:
            minping, avgping, maxping, pingstddev = map(float, output.split(b'= ')[1].replace(b'ms', b'').strip().split(b'/'))
            data[region] = {
              'host': host,
              'sucessful': True,
              'minping_sec': float("{0:.2f}".format(helpers.ms_to_s(minping))),
              'avgping_sec': float("{0:.2f}".format(helpers.ms_to_s(avgping))),
              'maxping_sec': float("{0:.2f}".format(helpers.ms_to_s(maxping))),
              'pingstddev_sec': float("{0:.2f}".format(helpers.ms_to_s(pingstddev)))
            }
      except:
        pass

    return data
