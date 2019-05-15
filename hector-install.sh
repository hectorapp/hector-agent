#!/bin/bash

########################################################################
# Author : Hutter Valentin
# Date : 15.05.2019
# Description : Diploma work - Hector agent monitoring - Installer
# School : CFPT-I, Geneva, T.IS-E2 A
########################################################################


### COLORS ###
COLOR_NC='\033[0m' # Default color
COLOR_BLUE='\033[94m'
COLOR_GREEN='\033[92m'
COLOR_RED='\033[91m'
COLOR_ORANGE='\033[93m'

### INSTALLER ###
if [ "$1" != "" ]; then
  # Init agent folder
  if [ ! -d /etc/hector-agent ]; then
    mkdir -p /etc/hector-agent;
  fi

  # Retrieves the agent from the github repository and install it
  cd /etc/hector-agent && wget --no-check-certificate --content-disposition https://github.com/valh1996/hector-agent/tarball/master -O hector-agent.tar.gz
  # Uncompress downloaded agent, and remove tar.gz
  tar -zxvf hector-agent.tar.gz && rm /etc/hector-agent/hector-agent.tar.gz
  # Get the the just downloaded archive name (random)
  install_dirname=`find /etc/hector-agent -name "valh1996-hector-agent-*" -type d`
  # Copy the content of uncompressed archive into /etc/hector-agent and remove it
  cp -a $install_dirname/. /etc/hector-agent/ && rm -rf $install_dirname
  # Remove hector-install.sh (useless, already installed)
  rm hector-install.sh

  # Download agent's python dependencies
  if [ -e /etc/hector-agent/requirements.txt ]; then
    echo -e "Downloading agent dependencies...";
    pip3 install -r requirements.txt && echo -e "${COLOR_GREEN}Dependencies have been downloaded!${COLOR_NC}"
  else
    echo -e "${COLOR_RED}An error occurred during the installation of the agent, please try again!${COLOR_NC}";
  fi

  # Sucessful installation
  echo -e "";
  echo -e "${COLOR_GREEN}Congratulations! Hector's agent has been successfully installed and is now collecting data on the server!${COLOR_NC}";
else
  echo -e "${COLOR_ORANGE}Unable to install hector, no token has been specified!${COLOR_NC}";
  echo -e "${COLOR_ORANGE}Try: ./hector-install.sh <token>${COLOR_NC}";
fi