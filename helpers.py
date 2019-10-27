#!/usr/bin/env python

'''
 * Author : Hutter Valentin
 * Date : 09.05.2019
 * Description : Hector agent monitoring
 * School : CFPT-I, Geneva, T.IS-E2 A
'''
import base64
import json

def bytes_to_mb(nb_bytes):
  return (nb_bytes / (1024 ** 2))

def bytes_to_gb(nb_bytes):
  return (nb_bytes / (1024 ** 3))

def ms_to_s(nb_ms):
  return (nb_ms / 1000)

def dict_to_base64(dictionary):
  return base64.urlsafe_b64encode(json.dumps(dictionary).encode()).decode()
