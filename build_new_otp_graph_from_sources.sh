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
OSM_PBF_URL_DEFAULT="http://download.geofabrik.de/europe/netherlands-latest.osm.pbf"
GTFS_URL_DEFAULT="http://gtfs.plannerstack.com/new/gtfs-nl.zip"
RAM_GB_DEFAULT="21"
OTP_JAR_NAME="otp.jar"
# GTFS_URL="http://gtfs.ovapi.nl/new/gtfs-nl.zip" # ALTERNATIVE

# INPUT ARGUMENTS
OTP_JAR_DIRECTORY="${1:-Undefined}"
BUILD_DIRECTORY="${2:-Undefined}"
OSM_PBF_URL="${3:-${OSM_PBF_URL_DEFAULT}}"
GTFS_URL="${4:-${GTFS_URL_DEFAULT}}"
RAM_GB="${5:-${RAM_GB_DEFAULT}}"

# INPUT VALIDATION
if [[ "${OTP_JAR_DIRECTORY}" == Undefined ]]; then echo "ERROR: NO OTP JAR DIRECTORY PASS ALONG"; exit; fi
if [[ "${BUILD_DIRECTORY}" == Undefined ]]; then echo "ERROR: NO BUILD DIRECTORY PASS ALONG"; exit; fi

CURRENT_DIRECTORY=$(pwd)
BUILD_DIRECTORY=$(cd "$BUILD_DIRECTORY" && pwd)
OTP_JAR_DIRECTORY=$(cd "$OTP_JAR_DIRECTORY" && pwd)

echo
echo
echo "BUILD_DIRECTORY: "
echo ${BUILD_DIRECTORY}
echo 
echo "OTP_JAR_DIRECTORY: "
echo ${OTP_JAR_DIRECTORY}
echo 
echo "CURRENT_DIRECTORY: "
echo ${CURRENT_DIRECTORY}
echo 

echo "1 CREATING BUILD DIRECTORY IF NECESSARY"
mkdir -p ${BUILD_DIRECTORY}
cd ${BUILD_DIRECTORY}

echo "2 DOWNLOADING OPENSTREETMAP DATA"
wget ${OSM_PBF_URL} -O osm.pbf --tries=1 --timeout=600

echo "3 DOWNLOADING GTFS DATA"
wget ${GTFS_URL} -O gtfs.zip --tries=1 --timeout=600

echo "4 BACKING UP LAST BUILD GRAPH AND SOURCES JSON"
if [ -f Graph.obj ]
then
    mv Graph.obj Graph.obj.last
fi
if [ -f lastBuildSources.json ]
then
    mv lastBuildSources.json lastBuildSources.json.last
fi

echo "5 SAVE CURRENT BUILD SOURCES"
echo ${SOURCES_JSON} >> lastBuildSources.json

echo "6 BUILD GRAPH"
time java -server -Xmx${RAM_GB}G -jar "${OTP_JAR_DIRECTORY}/${OTP_JAR_NAME}" --skipVisibility --longDistance --build .

echo "7 GO BACK TO WHERE WE CAME FROM"
cd ${CURRENT_DIRECTORY}

exit



# TODO:

# USE TIMESTAMPS TO ONLY DOWNLOAD IF NECESSARY
# Checking for existence of properties
# Use named variables