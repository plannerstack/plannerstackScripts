#!/usr/bin/env bash

# Fail correctly on pipes
set -o pipefail
# Exit on error
set -o errexit

# FOR DEBUGGING!
# set -o xtrace

# Set variables for current FILE, & DIR
__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"
__CURRENT_WORKING_DIR__=$(pwd)

# Exit when using undeclared variables
# set -o nounset # DOES NOT WORK NICELY WITH VIRTUALENV

command_exists () {
    type "$1" &> /dev/null ;
}

#
#
#
# END OF BASH SCRIPT BOILERPLATE http://kvz.io/blog/2013/11/21/bash-best-practices/
#
#
#

# INPUT ARGUMENTS
GRAPHTESTER_DIRECTORY="${1:-Undefined}"

# COMPUTED VARIABLES
GRAPHTESTER_DIRECTORY_ABS="${__CURRENT_WORKING_DIR__}/${GRAPHTESTER_DIRECTORY}"

# START ACTUAL SCRIPT
echo; echo "1 RUNNING THE TESTS"; echo;
cd ${GRAPHTESTER_DIRECTORY_ABS}
source graphTesterVirtualEnv/bin/activate
python2 mmri/test_otp.py tests/static-tests.json ../logging/`date +%Y-%m-%d.%H:%M:%S`.json -u http://0.0.0.0:9050/otp/routers/default/plan --today
deactivate

cd ${__CURRENT_WORKING_DIR__}