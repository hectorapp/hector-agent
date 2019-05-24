#!/bin/bash

########################################################################
# Author : Hutter Valentin
# Date : 24.05.2019
# Description : Diploma work - Hector agent monitoring - Installer
# School : CFPT-I, Geneva, T.IS-E2 A
########################################################################

INSTALLATION_PATH="/opt/hector-agent"
PYTHON_VERSION="3.7.3"

# Loading pyenv
pyenv_pre=$(which pyenv)

if [ $pyenv_pre="$HOME/.pyenv/bin/pyenv" ]
  then PYENV=$pyenv_pre
  else PYENV="$HOME/.pyenv/bin/pyenv"
fi

$PYENV init -
$PYENV virtualenv-init -
$PYENV local $PYTHON_VERSION
python3 hectoragent.py

unset PYENV
unset INSTALLATION_PATH
unset PYTHON_VERSION
unset pyenv_pre

exit 0