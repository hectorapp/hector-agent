#!/bin/bash

########################################################################
# Author : Hutter Valentin
# Date : 15.05.2019
# Description : Diploma work - Hector agent monitoring - Installer
# School : CFPT-I, Geneva, T.IS-E2 A
# Help :
#   - Using sed to replace text: https://stackoverflow.com/questions/11245144/replace-whole-line-containing-a-string-using-sed
#   - Create users on OSX:
#       - https://apple.stackexchange.com/questions/274954/cannot-create-a-user-account-on-mac-using-command-line
#       - https://pelaxa.com/blog/2015/03/17/creating-a-service-account-on-os-x-yosemite/
#   - Explain chmod in detail: https://www.poftut.com/chmod-755-700/
#   - Edit crontab from script: https://askubuntu.com/questions/880052/how-can-i-change-crontab-dynamically
########################################################################


### COLORS ###
COLOR_NC='\033[0m' # Default color
COLOR_BLUE='\033[94m'
COLOR_GREEN='\033[92m'
COLOR_RED='\033[91m'
COLOR_ORANGE='\033[93m'

# Welcome text
echo -e "${COLOR_BLUE}================================="
echo -e "Hector agent installation script"
echo -e "================================="
echo -e "${COLOR_NC}"

# Check that the installer is running as root
if [ $(id -u) != "0" ]; then
  echo -e "${COLOR_RED}Please run the install script as root. No worries, a new unprivileged user will be created just to run the agent itself.${COLOR_NC}"; 
  exit 1;
fi

### INSTALLER ###
if [ "$1" != "" ]; then
  echo -e "${COLOR_ORANGE}Downloading agent to /etc/hector-agent...${COLOR_NC}";

  # Init agent folder
  if [ ! -d /etc/hector-agent ]; then
    mkdir -p /etc/hector-agent;
  else
    # New Install - Delete previous agent
    rm -rf /etc/hector-agent/*
  fi

  echo -e "";
  
  # Retrieves the agent from the github repository and install it
  cd /etc/hector-agent && wget --no-check-certificate --content-disposition https://github.com/valh1996/hector-agent/tarball/master -O hector-agent.tar.gz
  # Uncompress downloaded agent, and remove tar.gz
  tar -zxvf hector-agent.tar.gz && rm /etc/hector-agent/hector-agent.tar.gz
  # Get the the just downloaded archive name (random)
  install_dirname=`find /etc/hector-agent -name "valh1996-hector-agent-*" -type d`
  # Copy the content of uncompressed archive into /etc/hector-agent and remove it
  cp -a $install_dirname/. /etc/hector-agent && rm -rf $install_dirname
  # Remove hector-install.sh (useless, already installed)
  rm hector-install.sh
  
  echo -e "${COLOR_GREEN}Agent downloaded!${COLOR_NC}";
  echo -e "";

  # Download agent's python dependencies
  if [ -e /etc/hector-agent/requirements.txt ]; then
    echo -e "Downloading agent dependencies...";
    pip3 install -r requirements.txt && echo -e "${COLOR_GREEN}Dependencies have been downloaded!${COLOR_NC}"
  else
    echo -e "${COLOR_RED}An error occurred during the installation of the agent, please try again!${COLOR_NC}";
    exit 1
  fi

  # Init logs directory
  cd /etc/hector-agent && mkdir logs && > crontab.log

  # Set API Token
  echo -e "${COLOR_GREEN}Set API Token...${COLOR_NC}";
  sed -i'' -e "s/.*token.*/token = ${1}/g" /etc/hector-agent/hectoragent.ini

  # Create unpriviliged user
  echo -e "${COLOR_GREEN}Create new user to run agent...${COLOR_NC}";
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    dscl . -create /Users/hectoragent
    dscl . -create /Users/hectoragent uid 300
    dscl . -create /Users/hectoragent gid 300
    dscl . -create /Users/hectoragent NFSHomeDirectory /etc/hector-agent
    dscl . -create /Users/hectoragent UserShell /usr/bin/false # Disable shell
    dscl . -create /Users/hectoragent RealName "Hector Agent"
    dscl . -create /Users/hectoragent passwd "*" # Special password linked to the group to prevent logins to the account
  else
    # New user named "hectoragent" with /etc/hector-agent home folder and shell login disabled
    useradd hectoragent -r -d /etc/hector-agent -s /bin/false
  fi

  # Change user permissions
  # User can read, write and execute, but group and others can't do anything
  echo -e "${COLOR_GREEN}Set user permissions...${COLOR_NC}";
  chown -R hectoragent: /etc/hector-agent && chmod -R 700 /etc/hector-agent
  
  # Register agent to crontab
  cronlines="*/3 * * * * python3 bash /etc/hector-agent/hectoragent.py > /etc/hector-agent/logs/crontab.log 2>&1" # Redirect standard error (stderr) to crontab.log
  echo "$cronlines" | crontab -u hectoragent - # Adding lines to crontab

  # Sucessful installation
  echo -e "";
  echo -e "${COLOR_GREEN}Congratulations! Hector's agent has been successfully installed and is now collecting data on the server!${COLOR_NC}";
else
  echo -e "${COLOR_ORANGE}Unable to install hector, no token has been specified!${COLOR_NC}";
  echo -e "${COLOR_ORANGE}Try: ./hector-install.sh <token>${COLOR_NC}";
fi

exit 0