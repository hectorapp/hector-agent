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
#   - Pyenv : https://github.com/pyenv/pyenv
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
PYTHON_VERSION="3.7.3"

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

#############################
### FUNCTIONS DECLARATION ###
#############################
install_pyenv_variables () {
  export PATH="~/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
}

install_pyenv_linux_distribution () {
  # Download pyenv
  PROJ=pyenv-installer
  SCRIPT_URL=https://github.com/pyenv/$PROJ/raw/master/bin/$PROJ
  curl -L $SCRIPT_URL < /dev/null | bash

  install_pyenv_variables
}

#############################
###       INSTALLER       ###
#############################
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
  ### Installing pyenv if not installed ###
  ##########################################
  if ! command -v pyenv &>/dev/null; then
    # Debian, Ubuntu, etc.
    if [ -n "$(command -v apt-get)" ]
		then
			echo -e "${COLOR_ORANGE}Installing pyenv through 'apt-get'...${COLOR_NC}";
      # Installing pyenv required libraries for Ubuntu/Debian
      sudo apt-get install -y \
        libbz2-dev \
        libsqlite3-dev \
        llvm \
        libncurses5-dev \
        libncursesw5-dev \
        tk-dev \
        liblzma-dev \
        git

      install_pyenv_linux_distribution
    # Fedora, CentOS, etc. Red Hat Enterprise Linux
		elif [ -n "$(command -v yum)" ]
		then
      echo -e "${COLOR_ORANGE}Installing pyenv through 'yum'...${COLOR_NC}";
      # Installing pyenv required libraries for "Red Hat distribuation"
      sudo yum install -y \
        zlib-devel \
        bzip2 \
        bzip2-devel \
        readline-devel \
        sqlite \
        sqlite-devel \
        openssl-devel \
        xz \
        xz-devel \
        libffi-devel \
        git
      
      install_pyenv_linux_distribution
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

      # Installing pyenv through homebrew
			echo -e "${COLOR_ORANGE}Installing pyenv through 'brew'...${COLOR_NC}"

		  sudo -u $CURRENT_USER brew install readline xz pyenv pyenv-virtualenv git
      install_pyenv_variables
		fi
  else
    echo -e "${COLOR_GREEN}Pyenv is already installed!${COLOR_NC}";
  fi

  # Test python after install
  if ! command -v pyenv &>/dev/null; then
    echo -e "${COLOR_RED}Unable to install pyenv, please restart the installation script or install pyenv manually!${COLOR_NC}";
    exit 1
  fi

  #########################################
  ###    Installing python version     ###
  #######################################
  # Prevent build failed when installing multi-version of python on MOJAVE
  # Help : http://www.blog.howechen.com/macos-mojave-pyenv-install-multi-version-build-failed-solution/
  if [[ "$OSTYPE" == "darwin"* ]]
	then
    osx_version=$(awk '/SOFTWARE LICENSE AGREEMENT FOR macOS/' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf' | awk -F 'macOS ' '{print $NF}' | awk '{print substr($0, 0, length($0))}')
    if [ $osx_version == "Mojave" ]
    then
      echo -e "${COLOR_ORANGE}Installing sdk-headers for osx... (to prevents build failed with python multi-versions)${COLOR_NC}";
      installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
    fi
  fi

  pyenv install $PYTHON_VERSION
  
  #########################################
  ### Installing pip3 if not installed ###
  #######################################
  if ! command -V pip3 &>/dev/null; then
    echo -e "${COLOR_ORANGE}Installing pip3...${COLOR_NC}";

    # Debian, Ubuntu, etc.
    if [ -n "$(command -v apt-get)" ]
		then
      apt-get install gcc python3-dev -y
    # Fedora, CentOS, etc. Red Hat Enterprise Linux
		elif [ -n "$(command -v yum)" ]
		then
      yum install -y gcc zlib-devel
    fi

    curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" --silent > /dev/null && python3 get-pip.py
    rm -rf get-pip.py
  else
    echo -e "${COLOR_GREEN}pip3 is already installed!${COLOR_NC}";
  fi

  #########################################
  ###          Install dig             ###
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

  #########################################
  ###   Create unpriviliged user       ###
  #######################################
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

  # Retrieves the agent from the github repository and install it
  cd $INSTALLATION_PATH && wget --no-check-certificate --content-disposition https://github.com/valh1996/hector-agent/tarball/master -O hector-agent.tar.gz
  # Uncompress downloaded agent, and remove tar.gz
  tar -zxvf hector-agent.tar.gz && rm $INSTALLATION_PATH/hector-agent.tar.gz
  # Get the the just downloaded archive name (random)
  install_dirname=`find $INSTALLATION_PATH -name "valh1996-hector-agent-*" -type d`
  # Copy the content of uncompressed archive into /opt/hector-agent and remove it
  cp -a $install_dirname/. $INSTALLATION_PATH && rm -rf $install_dirname
  # Remove hector-install.sh (useless, already installed)
  rm -rf hector-install.sh
  
  echo -e "${COLOR_GREEN}Agent downloaded!${COLOR_NC}";
  echo -e "";

  # Set python local version
  sudo -u $USER pyenv local $PYTHON_VERSION

  # Download agent's python dependencies
  if [ -e $INSTALLATION_PATH/requirements.txt ]; then
    echo -e "Downloading agent dependencies...";
    pip3 install -r requirements.txt && echo -e "${COLOR_GREEN}Dependencies have been downloaded!${COLOR_NC}"
  else
    echo -e "${COLOR_RED}An error occurred during the installation of the agent, please try again!${COLOR_NC}";
    exit 1
  fi

  # Init logs directory
  cd $INSTALLATION_PATH && mkdir logs && cd logs && > crontab.log

  # Set API Token
  echo -e "${COLOR_GREEN}Set API Token...${COLOR_NC}";
  sed -i'' -e "s/.*token.*/token = \"${1}\"/g" $INSTALLATION_PATH/hectoragent.ini

  # Change user permissions
  # User can read, write and execute, but group and others can't do anything
  echo -e "${COLOR_GREEN}Set user permissions...${COLOR_NC}";
  chown -R $USER: $INSTALLATION_PATH && chmod -R 700 $INSTALLATION_PATH

  # Register agent to crontab
  PYTHON_PATH=$(cd $INSTALLATION_PATH && pyenv which python3)
  cronlines="*/3 * * * * $PYTHON_PATH $INSTALLATION_PATH/hectoragent.py > $INSTALLATION_PATH/logs/crontab.log 2>&1" # Redirect standard error (stderr) to crontab.log
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
unset PYTHON_VERSION

exit 0