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

#
#
#
# END OF BASH SCRIPT BOILERPLATE http://kvz.io/blog/2013/11/21/bash-best-practices/
#
#
#

# DEFAULTS
RAM_GB_DEFAULT="21"
TMP_DIR_ABS_DEFAULT="/tmp/otp"
LOG_FILE_DEFAULT="mmri.log"

# INPUT ARGUMENTS
OTP_JAR="${1:-Undefined}"
GRAPH_DIRECTORY="${2:-Undefined}"
GRAPH_PROPERTIES_PATH="${3:-Undefined}"
LOG_FILE="${4:-${LOG_FILE_DEFAULT}}"
TMP_DIR_ABS="${5:-${TMP_DIR_ABS_DEFAULT}}"
RAM_GB="${6:-${RAM_GB_DEFAULT}}"

# INPUT VALIDATION
if [[ "${OTP_JAR}" == Undefined ]]; then echo "ERROR: NO OTP JAR PASS ALONG"; exit; fi
if [[ "${GRAPH_DIRECTORY}" == Undefined ]]; then echo "ERROR: NO GRAPH DIRECTORY PASS ALONG"; exit; fi
if [[ "${GRAPH_PROPERTIES_PATH}" == Undefined ]]; then echo "ERROR: NO GRAPH PROPERTIES PATH PASS ALONG"; exit; fi

# COMPUTED VARIABLES
OTP_JAR_ABS="${__CURRENT_WORKING_DIR__}/${OTP_JAR}"
GRAPH_DIRECTORY_ABS="${__CURRENT_WORKING_DIR__}/${GRAPH_DIRECTORY}"
GRAPH_PROPERTIES_PATH_ABS="${__CURRENT_WORKING_DIR__}/${GRAPH_PROPERTIES_PATH}"
LOG_FILE_ABS="${__CURRENT_WORKING_DIR__}/${LOG_FILE}"

# COMPUTED VARIABLES VALIDATION
if [ ! -e "${OTP_JAR_ABS}" ]; then echo "ERROR: NO JAR FILE FOUND IN GIVEN PATH"; exit; fi
if [ ! -d "${GRAPH_DIRECTORY_ABS}" ]; then echo "ERROR: NO GRAPH DIRECTORY FOUND IN GIVEN PATH"; exit; fi
if [ ! -e "${GRAPH_PROPERTIES_PATH_ABS}" ]; then echo "ERROR: NO GRAPH PROPERTIESFILE FOUND IN GIVEN PATH"; exit; fi
if [ ! -d "${TMP_DIR_ABS_DEFAULT}" ]; then echo "ERROR: NO TMP DIRE FOUND IN GIVEN PATH"; exit; fi

# START ACTUAL SCRIPT
echo "1 COPYING GIVING GRAPH PROPERTIES FILE TO GRAPH BUILD DIRECTORY"
GRAPH_PROPERTIES_CONTENT=$(<${GRAPH_PROPERTIES_PATH_ABS})
echo "${GRAPH_PROPERTIES_CONTENT}" >> ${GRAPH_DIRECTORY_ABS}/Graph.properties

echo "2 STARTING UP OTP"
nohup java -Djava.io.tmpdir=${TMP_DIR_ABS} -XX:NewRatio=1 -Xms${RAM_GB}G -Xmx${RAM_GB}G -XX:+OptimizeStringConcat -XX:+UseStringCache -XX:+UseConcMarkSweepGC -server -jar ${OTP_JAR_ABS} --server  --longDistance -g ${GRAPH_DIRECTORY_ABS} -p 9050 | tee ${LOG_FILE_ABS} &

exit