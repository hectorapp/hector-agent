#!/usr/bin/env python
# coding: utf-8

'''
 * Author : Hutter Valentin
 * Date : 22.05.2019
 * Description : Hector agent monitoring
'''

import sys
import psutil
import requests
from subprocess import Popen, PIPE
sys.path.insert(0, '..') # to import helpers from parent folder
import helpers

class ip:

  def _get_ips_data(self, nic):
    result = []
    data = {
      'ip': None,
      'is_private': False,
      'country_code': None,
      'country_name': None,
      'latitude': None,
      'longitude': None,
      'region_code': None,
      'region_name': None
    }

    try:
      params_ip = {
        'ipv4': '-4',
        'ipv6': '-6'
      }

      for key in params_ip:
        command = 'dig ' + params_ip[key] + ' TXT +short o-o.myaddr.l.google.com @ns1.google.com'

        ip = Popen(command, shell=True, stdout=PIPE)
        output = ip.communicate()[0]
        
        if output:
          ip = output.decode("utf-8").strip().strip('"')

          if not any(d['ip'] == ip for d in result):
            res = requests.get(url='https://freegeoip.app/json/' + ip)
            json = res.json()

            if json:
              data['ip'] = json['ip']
              data['country_code'] = json['country_code']
              data['country_name'] = json['country_name']
              data['latitude'] = json['latitude']
              data['longitude'] = json['longitude']
              data['region_code'] = json['region_code']
              data['region_name'] = json['region_name']

            result.append(data)
    except:
      pass

    return result

  def _is_valid_ipv6_address(address):
    try:
        socket.inet_pton(socket.AF_INET6, address)
    except socket.error:
        return False
    return True

  def _get_default_nic(self):
    command = ''

    if psutil.MACOS:
      command = "route -n get default | grep 'interface:' | grep -o '[^ ]*$'"
    else:
      command = "route | grep '^default' | grep -o '[^ ]*$'"

    nic = Popen(command, shell=True, stdout=PIPE)
    output = nic.communicate()[0]

    return output.decode("utf-8").strip().strip('"')

  def collect_ips(self):
    # Collect ips data
    return self._get_ips_data(self._get_default_nic())
