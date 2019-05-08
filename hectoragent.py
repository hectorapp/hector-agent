#!/usr/bin/env python3

'''
 * Author : Hutter Valentin
 * Date : 08.05.2019
 * Description : Diploma work - Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
'''

import sys
import pyfiglet

AGENT_VERSION = '1.0.0'

##############################
# Print ascii logo of hector#
############################
def getLogo():
  ascii_logo = pyfiglet.figlet_format("Hector Agent")
  print(ascii_logo)
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
    print('Run agent')


main()