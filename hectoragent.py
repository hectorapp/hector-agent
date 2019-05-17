#!/usr/bin/env python3

'''
 * Author : Hutter Valentin
 * Date : 08.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
 * Help :
 *  - Requests: https://2.python-requests.org/en/master/
'''

import sys
import pyfiglet
import os
import platform
import configparser
import requests
import datetime
import helpers
import psutil
# Import modules
from modules.colors import colors
from modules.memory import memory
from modules.swap import swap
from modules.disk import disk
from modules.network import network
from modules.load import load
from modules.process import process
from modules.ping import ping
from modules.cpu import cpu

AGENT_VERSION = '1.0.0'
API_ENDPOOINT = 'http://hector-api.test'

'''
Class who manages the agent
'''
class HectorAgent:

  def __init__(self):
    print(colors.ORANGE + "Starting hector agent..." + colors.NORMAL)

  def _server_platform(self):
    return platform.platform()

  # Collect and sendit to API
  def collect_data(self):
    if os.path.exists('./hectoragent.ini'):
      config = configparser.ConfigParser()
      config.read('hectoragent.ini') # Loading configuration
      token = config['API']['token'].strip('"') # Get token from .ini configuration
      
      # Collecting data
      print('\nCollecting Data...')
      mem = memory().collect()
      swap_mem = swap().collect()
      disk_usage_overall = disk().collect_overall_disk_usage()
      disk_partitions = disk().collect_partitions()
      disk_io = disk().collect_io()
      net = network().collect_network_addrs()
      server_loads = load().collect()
      processes = process().collect()
      extern_ping = ping().collect()
      server_cpu = cpu().collect()
      boot_time = float(psutil.boot_time())

      # Sending data to the API
      try:
        print('Sending data to API...')
        res = requests.post(API_ENDPOOINT + "/servers?server_token=" + token, data={
          'os_fullname': self._server_platform(),
          'boot_time': boot_time,
          'memory': helpers.dict_to_base64(mem),
          'swap': helpers.dict_to_base64(swap_mem),
          'disk_usage_overall': helpers.dict_to_base64(disk_usage_overall),
          'disk_partitions': helpers.dict_to_base64(disk_partitions),
          'disk_io': helpers.dict_to_base64(disk_io),
          'network': helpers.dict_to_base64(net),
          'loads': helpers.dict_to_base64(server_loads),
          'processes': helpers.dict_to_base64(processes),
          'extern_ping': helpers.dict_to_base64(extern_ping),
          'cpu': helpers.dict_to_base64(server_cpu),
          'request_send_at': datetime.datetime.now().timestamp(),
        })
        
        print(res.text)

        if res.status_code == 200:
          print(colors.GREEN + '\nThe data has been correctly sent to the API!' + colors.NORMAL)

      except requests.exceptions.RequestException:
        sys.exit(1)
    
  # Start the agent
  def start(self):
    print(colors.GREEN + 'Hector agent has started!' + colors.NORMAL)
    self.collect_data()

'''
Print ascii logo of hector
'''
def getLogo():
  ascii_logo = pyfiglet.figlet_format("Hector Agent")
  print(colors.CBLUE + ascii_logo + colors.NORMAL)
  print('')

'''
Entry point of agent
'''
def main():
  getLogo()

  if len(sys.argv) > 1:
    # Help argument
    if sys.argv[1] == 'help':
      print ('\n'.join((
          'To start the agent, run it without specifying an argument.',
          'Available optional arguments (hectoragent.py <argument>):',
          '  help',
          '  version',
      )))
      sys.exit()
    if sys.argv[1] == 'version':
      print('Agent run on version: ' + AGENT_VERSION)
      sys.exit()
  else:
    HectorAgent().start()

if __name__ == '__main__':
    main()