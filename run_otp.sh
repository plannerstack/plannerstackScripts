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
TMP_DIRECTORY="/tmp/otp"
LOG_FILE_DIRECTORY_DEFAULT="."
LOG_FILE_NAME="otp.log"
OTP_JAR_FILE_NAME="otp.jar"
GRAPH_PROPERTY_FILE_NAME="Graph.properties"

# INPUT ARGUMENTS
OTP_JAR_DIRECTORY="${1:-Undefined}"
GRAPH_DIRECTORY="${2:-Undefined}"
GRAPH_PROPERTIES_DIRECTORY="${3:-Undefined}"
LOG_FILE_DIRECTORY="${4:-${LOG_FILE_DIRECTORY_DEFAULT}}"
RAM_GB="${5:-${RAM_GB_DEFAULT}}"

# INITIAL INPUT VALIDATION
if [[ "${OTP_JAR_DIRECTORY}" == Undefined ]]; then echo "INFO: Pass along a directory containing an '"${OTP_JAR_FILE_NAME}"' file"; exit; fi
if [[ "${GRAPH_DIRECTORY}" == Undefined ]]; then echo "ERROR: Pass along a directory contianing your .pbf and gtfs files"; exit; fi
if [[ "${GRAPH_PROPERTIES_DIRECTORY}" == Undefined ]]; then echo "ERROR: Pass along a directory that contains a "${GRAPH_PROPERTY_FILE_NAME}; exit; fi

OTP_JAR_DIRECTORY=$(cd "$OTP_JAR_DIRECTORY" && pwd)
GRAPH_DIRECTORY=$(cd "$GRAPH_DIRECTORY" && pwd)
GRAPH_PROPERTIES_DIRECTORY=$(cd "$GRAPH_PROPERTIES_DIRECTORY" && pwd)
LOG_FILE_DIRECTORY=$(cd "$LOG_FILE_DIRECTORY" && pwd)

if [[ "${OTP_JAR_DIRECTORY}/${OTP_JAR_FILE_NAME}" == Undefined ]]; then echo "INFO: Pass along a directory containing an '"${OTP_JAR_FILE_NAME}"' file"; exit; fi
if [[ "${GRAPH_PROPERTIES_DIRECTORY}/${GRAPH_PROPERTY_FILE_NAME}" == Undefined ]]; then echo "ERROR: Pass along a directory that contains a "${GRAPH_PROPERTY_FILE_NAME}; exit; fi

# START ACTUAL SCRIPT
echo; echo "1 COPYING GIVING GRAPH PROPERTIES FILE TO GRAPH BUILD DIRECTORY AS THAT'S WHERE OTP EXPECTS IT TO BE"; echo;
cp "${GRAPH_PROPERTIES_DIRECTORY}/${GRAPH_PROPERTY_FILE_NAME}" "${GRAPH_DIRECTORY}/${GRAPH_PROPERTY_FILE_NAME}"

echo; echo "2 MAKE SURE TMP DIRECTORY IS THERE"; echo;
mkdir -p ${TMP_DIRECTORY}

echo; echo "3 STARTING UP OTP"; echo;
nohup java -Djava.io.tmpdir=${TMP_DIRECTORY} -XX:NewRatio=1 -Xms${RAM_GB}G -Xmx${RAM_GB}G -XX:+OptimizeStringConcat -XX:+UseStringCache -XX:+UseConcMarkSweepGC -server -jar ${OTP_JAR_DIRECTORY}/${OTP_JAR_FILE_NAME} --server  --longDistance -g ${GRAPH_DIRECTORY} -p 9050 2>&1 | tee ${LOG_FILE_DIRECTORY}/${LOG_FILE_NAME} &

cd ${__DIR__}
exit