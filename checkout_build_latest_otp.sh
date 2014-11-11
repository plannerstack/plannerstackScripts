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
set -o nounset

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

# DEFAULTS
OTP_DIRECTORY_DEFAULT="openTripPlanner"
OTP_GIT_URL_DEFAULT="https://github.com/opentripplanner/OpenTripPlanner.git"
OTP_BRANCH_DEFAULT="master"

# INPUT ARGUMENTS
OTP_DIRECTORY="${1:-${OTP_DIRECTORY_DEFAULT}}"
OTP_GIT_URL="${2:-${OTP_GIT_URL_DEFAULT}}"
OTP_BRANCH="${3:-${OTP_BRANCH_DEFAULT}}"

# INPUT VALIDATION
if [[ "${OTP_DIRECTORY}" == Undefined ]]; then echo "ERROR: NO OTP JAR PASS ALONG"; exit; fi

# COMPUTED VARIABLES
OTP_DIRECTORY_ABS="${__CURRENT_WORKING_DIR__}/${OTP_DIRECTORY}"

# COMPUTED VARIABLES VALIDATION
if [ ! -d "${OTP_DIRECTORY_ABS}" ]; then echo "ERROR: NO DIRECTORY FOUND ON GIVE PATH: FIRST CREATE EMPTY DIRECTORY"; exit; fi
if (! command_exists mvn); then
	echo "ERROR: MAVEN IS NOT INSTALLED!";    
fi


# START ACTUAL SCRIPT
echo; echo "1 CLONING OTP FROM ${OTP_GIT_URL} IF NEEDED"; echo;
cd ${OTP_DIRECTORY_ABS}
if [ ! -d .git ]; then
    git clone ${OTP_GIT_URL} .
fi

echo; echo "2 FORCE CHECKOUT BRANCH: ${OTP_BRANCH}"; echo;
git checkout -f HEAD^
git checkout -f ${OTP_BRANCH}
git pull

echo; echo "3 BUILD OTP"; echo;
mvn clean verify # -DskipTests # Or skip tests if you don't want to

cd ${__DIR__}

exit
