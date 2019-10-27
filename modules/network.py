#!/usr/bin/env python
# coding: utf-8

'''
 * Author : Hutter Valentin
 * Date : 09.05.2019
 * Description : Hector agent monitoring
 * Help: 
 *  - https://psutil.readthedocs.io/en/latest/#psutil.net_io_counters
 *  - https://psutil.readthedocs.io/en/latest/#psutil.net_if_addrs
'''

import psutil
import ipaddress
import socket
import sys
sys.path.insert(0, '..') # to import helpers from parent folder
import helpers

class network:

  def collect_network_addrs(self):
    network_stats = psutil.net_io_counters(pernic=True) # True -> return the same information for every physical disk installed
    net_interfaces = psutil.net_if_addrs()
    results = {}

    for key, values in net_interfaces.items():
      net_stats = network_stats[key]
      results[key] = {
        'interface': key,
        'address': values[0].address,
        'bytes_sent_mb': float("{0:.2f}".format(helpers.bytes_to_mb(net_stats.bytes_sent))),
        'bytes_received_mb': float("{0:.2f}".format(helpers.bytes_to_mb(net_stats.bytes_recv))),
        'packets_sent': net_stats.packets_sent,
        'packets_received': net_stats.packets_recv,
        'err_received': net_stats.errin, # total number of errors while receiving
        'err_sent': net_stats.errout, # total number of errors while sending
        'err_packets_sent': net_stats.dropin, #total number of incoming packets which were dropped
        'err_packets_received': net_stats.dropout # total number of outgoing packets which were dropped (always 0 on macOS and BSD)
      }
        
    return results
