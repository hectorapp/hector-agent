#!/bin/bash

########################################################################
# Author : Hutter Valentin
# Date : 24.05.2019
# Description : Diploma work - Hector agent monitoring - Installer
# School : CFPT-I, Geneva, T.IS-E2 A
########################################################################

PYENV=$(which pyenv)
INSTALLATION_PATH="/opt/hector-agent"
PYTHON_VERSION="3.7.3"

$PYENV init -
$PYENV virtualenv-init -
$PYENV local 3.7.3
python3 hectoragent.py

unset PYENV
unset INSTALLATION_PATH
unset PYTHON_VERSION

exit 0