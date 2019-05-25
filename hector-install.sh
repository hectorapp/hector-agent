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
#   - Get the name of the user who executed a bash script as sudo?: https://unix.stackexchange.com/questions/137175/how-to-get-the-name-of-the-user-who-executed-a-bash-script-as-sudo
########################################################################

### COLORS ###
COLOR_NC='\033[0m' # Default color
COLOR_BLUE='\033[94m'
COLOR_GREEN='\033[92m'
COLOR_RED='\033[91m'
COLOR_ORANGE='\033[93m'

# Global variables
INSTALLATION_PATH="/opt/hector-agent"
USER="hectoragent"
API_ENDPOINT="https://hectorapi.valentinhutter.ch"

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

#################
### INSTALLER ###
#################
if [ "$1" != "" ]; then
  echo -e "${COLOR_ORANGE}Downloading agent to ${INSTALLATION_PATH}...${COLOR_NC}";

  # Init agent folder
  if [ -d $INSTALLATION_PATH ]; then
    # If an installation is already present, ask the user for confirmation for reinstallation
    read -p "A Hector installation is already present, do you really want to reinstall it? [y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]
    then
      exit 0
    fi

    # New Install - Delete previous agent
    rm -rf $INSTALLATION_PATH/*
  fi

  mkdir -p $INSTALLATION_PATH
  echo -e "";

  ############################################
  ### Installing python3 if not installed ###
  ##########################################
  if ! command -V /usr/local/bin/python3.7 &>/dev/null; then
    # Debian, Ubuntu, etc.
    if [ -n "$(command -v apt-get)" ]
		then
			echo -e "${COLOR_ORANGE}Installing python3 through 'apt-get'...${COLOR_NC}";
      apt-get install gcc python3-dev -y
    # Fedora, CentOS, etc. Red Hat Enterprise Linux
		elif [ -n "$(command -v yum)" ]
		then
      echo -e "${COLOR_ORANGE}Installing python3 through 'yum'...${COLOR_NC}";
      yum -y install gcc

      # Fedora install python3-dev
      if [ -n "$(command --version dnf)" ]
      then
        dnf install python3-devel -y
      # openSUSE
      elif [ -n "$(command --version zypper)" ]
      then
        zypper in python3-devel -n
      fi
    # OSX
		elif [[ "$OSTYPE" == "darwin"* ]]
		then
      # Retrieves the username of the user who executed the script as root to launch 
      # the Homebrew installation as non-root (required for security reasons)
      CURRENT_USER=$(printf '%s\n' "${SUDO_USER:-$USER}")

      if [ ! -n "$(command -v brew)" ]; then
        echo -e "${COLOR_ORANGE}Installing homebrew...${COLOR_NC}";
  
        # Homebrew require xcode packages, so install it
        if [ ! -n "$(command -v xcode-select)" ]; then
          echo -e "${COLOR_ORANGE}Installing Apple’s Xcode package...${COLOR_NC}";
          xcode-select --install
          echo -e "${COLOR_GREEN}Apple’s Xcode package is now installed!${COLOR_NC}";
        fi
        
        sudo -u $CURRENT_USER /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null # Redirect to /dev/null to prevent prompt
        echo -e "${COLOR_ORANGE}Homebrew is now installed!${COLOR_NC}"
      fi

      # Installing python3 through homebrew
			echo -e "${COLOR_ORANGE}Installing python3 through 'brew'...${COLOR_NC}"
		  sudo -u $CURRENT_USER brew install gcc
		fi

    # Installing python from sources
    wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz &&
    tar xfv Python-3.7.3.tar.xz &&
    cd Python-3.7.3 &&
    CXX="/usr/bin/g++" ./configure --prefix=/usr/local --enable-shared --with-ensurepip=yes &&
    make &&
    sudo make install &&
    chmod -v 755 /usr/local/lib/libpython3.7m.so &&
    chmod -v 755 /usr/local/lib/libpython3.so &&
    cd .. &&
    rm -rf Python-3.7.3.tar.xz &&
    Python-3.7.3
  else
    echo -e "${COLOR_GREEN}Python is already installed!${COLOR_NC}";
  fi

  # Test python after install
  if ! command -V /usr/local/bin/python3.7 &>/dev/null; then
    echo -e "${COLOR_RED}Unable to install python3, please restart the installation script or install python3 manually!${COLOR_NC}";
    exit 1
  fi

  ############################################
  ###         Installing crontab          ###
  ##########################################
  if [ ! -n "$(command -v crontab)" ]
  then
    # Ask user to confirm crontab installation (required)
    read -p "Crontab is not installed, but is required to run hector. Would you like to install it? [y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      #
      # Install crontab
      #

      # Debian, Ubuntu, etc.
      if [ -n "$(command -v apt-get)" ]
      then
        echo -e "${COLOR_ORANGE}[REQUIRED]${COLOR_NC} Installing cron through 'apt-get'...";
        apt-get -y update
        apt-get -y install cron
      # Fedora, CentOS, etc. Red Hat Enterprise Linux
      elif [ -n "$(command -v yum)" ]
      then
        echo -e "${COLOR_ORANGE}[REQUIRED]${COLOR_NC} Installing cronie through 'yum'...";
        yum -y install cronie
          
        # Cronie-vixie installation if the crontab is still not available after the cronie installation
        if [ ! -n "$(command -v crontab)" ]
        then
          echo -e "${COLOR_ORANGE}[REQUIRED]${COLOR_NC} Installing vixie-cron through 'yum'...";
          yum -y install vixie-cron
        fi
      fi
    fi
    
    # Test crontab install after installation
    if [ ! -n "$(command -v crontab)" ]
    then
      echo -e "${COLOR_RED}Unable to install crontab, but it is required. Please install it manually and restart the script.${COLOR_NC}"
      exit 1
    fi	
  fi

  ############################################
  ###          Starting crontab           ###
  ##########################################
  # Check if cron is running
  if [ -z "$(ps -Al | grep cron | grep -v grep)" ]
  then
    # Ask user to confirm crontab start (required)
    read -p "Crontab is installed, but not started. Hector needs it to work. Do you confirm the start? [y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      #
      # Starting crontab
      #
      echo -e "${COLOR_ORANGE}Starting crontab....${COLOR_NC}";
      
      # Debian, Ubuntu, etc.
      if [ -n "$(command -v apt-get)" ]
      then
        service cron start
      # Fedora, CentOS, etc. Red Hat Enterprise Linux
      elif [ -n "$(command -v yum)" ]
      then
        chkconfig crond on
        service crond start
      fi
    fi
    
    # Checks that the start of crontab has worked well
    if [ -z "$(ps -Al | grep cron | grep -v grep)" ]
    then
      echo -e "${COLOR_RED}Unable to start the crontab, please try again or start it manually, then restart the installation script...${COLOR_NC}"
      exit 1
    fi
  fi

  #########################################
  ###          Installing dig          ###
  #######################################
  if ! command -v dig &>/dev/null; then
    echo -e "${COLOR_ORANGE}Installing dig...${COLOR_NC}";

    # Debian, Ubuntu, etc.
    if [ -n "$(command -v apt-get)" ]
		then
      apt-get install dnsutils -y
    # Fedora, CentOS, etc. Red Hat Enterprise Linux
		elif [ -n "$(command -v yum)" ]
		then
      yum -y install bind-utils
    elif [[ "$OSTYPE" == "darwin"* ]]
		then
      CURRENT_USER=$(printf '%s\n' "${SUDO_USER:-$USER}")
      sudo -u $CURRENT_USER brew install bind
    fi
  else
    echo -e "${COLOR_GREEN}dig is already installed!${COLOR_NC}";
  fi

  # Retrieves the agent from the github repository and install it
  cd $INSTALLATION_PATH && wget --no-check-certificate --content-disposition https://github.com/valh1996/hector-agent/tarball/master -O hector-agent.tar.gz
  # Uncompress downloaded agent, and remove tar.gz
  tar -zxvf hector-agent.tar.gz && rm $INSTALLATION_PATH/hector-agent.tar.gz
  # Get the the just downloaded archive name (random)
  install_dirname=`find $INSTALLATION_PATH -name "valh1996-hector-agent-*" -type d`
  # Copy the content of uncompressed archive into /opt/hector-agent and remove it
  cp -a $install_dirname/. $INSTALLATION_PATH && rm -rf $install_dirname
  # Remove hector-install.sh (useless, already installed)
  rm hector-install.sh
  
  echo -e "${COLOR_GREEN}Agent downloaded!${COLOR_NC}";
  echo -e "";

  # Download agent's python dependencies
  if [ -e $INSTALLATION_PATH/requirements.txt ]; then
    echo -e "Downloading agent dependencies...";
    /usr/local/bin/python3.7 -m pip install -r requirements.txt && 
    echo -e "${COLOR_GREEN}Dependencies have been downloaded!${COLOR_NC}"
  else
    echo -e "${COLOR_RED}An error occurred during the installation of the agent, please try again!${COLOR_NC}";
    exit 1
  fi

  # Set API Token
  echo -e "${COLOR_GREEN}Set API Token...${COLOR_NC}";
  sed -i'' -e "s/.*token.*/token = \"${1}\"/g" $INSTALLATION_PATH/hectoragent.ini

  # Create unpriviliged user
  echo -e "${COLOR_GREEN}Create new user to run agent...${COLOR_NC}";
  if [[ "$OSTYPE" == "darwin"* ]]; then
    ## OSX ##

    # Delete previous user if agent is reinstalled
    if [ `dscl . list /Users | grep -v "^_" | grep $USER` == $USER ]; then
      echo -e "${COLOR_ORANGE}A hectoragent user already exists, deletes user and creating it again...${COLOR_NC}";
      dscl . delete /Users/$USER
      rm -rf /Users/$USER
    fi

    # Adding hectoragent user
    dscl . -create /Users/$USER
    dscl . -create /Users/$USER uid 300
    dscl . -create /Users/$USER gid 300
    dscl . -create /Users/$USER NFSHomeDirectory $INSTALLATION_PATH
    dscl . -create /Users/$USER UserShell /usr/bin/false # Disable shell
    dscl . -create /Users/$USER RealName "Hector Agent"
    dscl . -create /Users/$USER passwd "*" # Special password linked to the group to prevent logins to the account
  else
    ## OTHER : LINUX ##
    if id -u $USER >/dev/null 2>&1
	  then
      echo -e "${COLOR_ORANGE}A hectoragent user already exists, deletes user and creating it again...${COLOR_NC}";
      userdel $USER
    fi

    # New user named "$USER" with "$INSTALLATION_PATH" home folder and shell login disabled
    useradd $USER -r -d $INSTALLATION_PATH -s /bin/false
  fi

  # Change user permissions
  # User can read, write and execute, but group and others can't do anything
  echo -e "${COLOR_GREEN}Set user permissions...${COLOR_NC}";
  chown -R $USER: $INSTALLATION_PATH && chmod -R 700 $INSTALLATION_PATH
  
  # Register agent to crontab
  cronlines="*/3 * * * * /usr/local/bin/python3.7 $INSTALLATION_PATH/hectoragent.py" # Redirect standard error (stderr) to crontab.log
  echo "$cronlines" | crontab -u $USER - # Adding lines to crontab

  ########################
  # Sucessful installation
  ########################

  # Indicates to the web application that the agent has been installed
  curl -d "server_token=${1}" -X POST "${API_ENDPOINT}/servers/installed" --silent > /dev/null
  # Set agent has installed in local
  sed -i'' -e "s/.*installed.*/installed = yes/g" $INSTALLATION_PATH/hectoragent.ini

  echo -e "";
  echo -e "${COLOR_GREEN}Congratulations! Hector's agent has been successfully installed and is now collecting data on the server!${COLOR_NC}";
else
  echo -e "${COLOR_ORANGE}Unable to install hector, no token has been specified!${COLOR_NC}";
  echo -e "${COLOR_ORANGE}Try: ./hector-install.sh <token>${COLOR_NC}";
fi

# Unsetting variables
unset COLOR_NC
unset COLOR_BLUE
unset COLOR_GREEN
unset COLOR_RED
unset COLOR_ORANGE
unset INSTALLATION_PATH
unset USER
unset API_ENDPOINT

exit 0