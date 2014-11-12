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

CURRENT_WORKING_DIR=$(pwd)

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
LOGGING_DIRECTORY="${2:-Undefined}"

GRAPHTESTER_DIRECTORY=$(cd "$GRAPHTESTER_DIRECTORY" && pwd)
LOGGING_DIRECTORY=$(cd "$LOGGING_DIRECTORY" && pwd)


# INPUT VALIDATION
if [[ "${GRAPHTESTER_DIRECTORY}" == Undefined ]]; then echo "ERROR: NO GRAPHTESTER_DIRECTORY PASS ALONG"; exit; fi
if [[ "${LOGGING_DIRECTORY}" == Undefined ]]; then echo "ERROR: NO LOGGING_DIRECTORY PASS ALONG"; exit; fi


# START ACTUAL SCRIPT
echo; echo "1 RUNNING THE TESTS"; echo;
cd ${GRAPHTESTER_DIRECTORY}
source graphTesterVirtualEnv/bin/activate
python2 mmri/test_otp.py tests/static-tests.json "${LOGGING_DIRECTORY}/`date +%Y-%m-%d.%H:%M:%S`.json" -u http://0.0.0.0:9050/otp/routers/default/plan --today
deactivate

cd ${CURRENT_WORKING_DIR}