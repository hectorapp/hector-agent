#!/usr/bin/env python3
# coding: utf-8

'''
 * Author : Hutter Valentin
 * Date : 22.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
 * Help :
    - Get public ip with DNS server : 
      - https://www.cyberciti.biz/faq/how-to-find-my-public-ip-address-from-command-line-on-a-linux/
      - https://unix.stackexchange.com/questions/477705/resolve-my-ip-with-dig-returns-empty-string
    - Linux IP : https://stackoverflow.com/questions/21336126/linux-bash-script-to-extract-ip-address
'''

import sys
import psutil
from subprocess import Popen, PIPE
sys.path.insert(0, '..') # to import helpers from parent folder
import helpers

class ip:

  def _exec_command_ip(self, command, private):
    data = {}

    try:
      private_ip = Popen(command, shell=True, stdout=PIPE)
      output = private_ip.communicate()[0]

      if output:
        data = {
          'ip': output.decode("utf-8").strip(),
          'is_private': private,
        }

    except:
      pass

    return data

  def public_ip(self):
    # Using a DNS server to retrieve the public IP
    return self._exec_command_ip('dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com', False)

  def private_ip(self):
    command = ''
    
    # Generates command depending on OS
    if psutil.MACOS:
      command = 'ipconfig getifaddr en0'
    else:
      command = "hostname -I | awk '{ print $1 }'"

    return self._exec_command_ip(command, True)

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