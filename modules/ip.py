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

  def _get_ip_data(self, private = True):
    data = {
      'ip': None,
      'is_private': private,
      'country_code': None,
      'country_name': None,
      'latitude': None,
      'longitude': None,
      'region_code': None,
      'region_name': None
    }

    try:
      if private:
        command = ''

        # Generates command depending on OS
        if psutil.MACOS:
          command = 'ipconfig getifaddr en0'
        else:
          command = "hostname -I | awk '{ print $1 }'"

        private_ip = Popen(command, shell=True, stdout=PIPE)
        output = private_ip.communicate()[0]

        if output:
          data['ip'] = output.decode("utf-8").strip().strip('"')
      else:
        res = requests.get(url='https://freegeoip.app/json')
        json = res.json()

        if json:
          data['ip'] = json['ip']
          data['country_code'] = json['country_code']
          data['country_name'] = json['country_name']
          data['latitude'] = json['latitude']
          data['longitude'] = json['longitude']
          data['region_code'] = json['region_code']
          data['region_name'] = json['region_name']
    except:
      pass

    return data

  def public_ip(self):
    return self._get_ip_data(False)

  def private_ip(self):
    return self._get_ip_data(True)

  def collect_ips(self):
    # Collect public ip 
    public_ip = []
    public_ip.append(self.public_ip())

    # Collect private ips
    private_ip = []
    private_ip.append(self.private_ip())

    # Merge public and private ips together
    ips = public_ip + private_ip

    return ips
