#!/usr/bin/env python3

'''
 * Author : Hutter Valentin
 * Date : 08.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
'''

import sys
import pyfiglet
import os
import platform
# Import modules
from modules.colors import colors
from modules.memory import memory
from modules.swap import swap
from modules.disk import disk

AGENT_VERSION = '1.0.0'

###############################
# Class who manages the agent#
#############################
class HectorAgent:
  def __init__(self):
    print(colors.ORANGE + "Starting hector agent..." + colors.NORMAL)


  def server_platform(self):
    return platform.platform()

  # Collect server data
  def collect_data(self):
    #self.server_platform()
    #memory().collect()
    #swap().collect()
    #disk().collect_partitions()
    print(disk().collect_overall_disk_usage())
    
  # Start the agent
  def start(self):
    print(colors.GREEN + 'Hector agent has started!' + colors.NORMAL)
    self.collect_data()

##############################
# Print ascii logo of hector#
############################
def getLogo():
  ascii_logo = pyfiglet.figlet_format("Hector Agent")
  print(colors.BLUE + ascii_logo + colors.NORMAL)
  print('')

#########################
# Entry point of agent #
#######################
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
  else:
    HectorAgent().start()

if __name__ == '__main__':
    main()