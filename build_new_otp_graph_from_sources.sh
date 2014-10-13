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
# GTFS_URL="http://gtfs.ovapi.nl/new/gtfs-nl.zip" # ALTERNATIVE

# INPUT ARGUMENTS
OTP_JAR="${1:-Undefined}"
BUILD_DIRECTORY="${2:-Undefined}"
OSM_PBF_URL="${3:-${OSM_PBF_URL_DEFAULT}}"
GTFS_URL="${4:-${GTFS_URL_DEFAULT}}"
RAM_GB="${5:-${RAM_GB_DEFAULT}}"

# INPUT VALIDATION
if [[ "${OTP_JAR}" == Undefined ]]; then echo "ERROR: NO OTP JAR PASS ALONG"; exit; fi
if [[ "${BUILD_DIRECTORY}" == Undefined ]]; then echo "ERROR: NO BUILD DIRECTORY PASS ALONG"; exit; fi

# COMPUTED VARIABLES
OTP_JAR_ABS="${__CURRENT_WORKING_DIR__}/${OTP_JAR}"
BUILD_DIRECTORY_ABS="${__CURRENT_WORKING_DIR__}/${BUILD_DIRECTORY}"
SOURCES_JSON="{\"osm.pbf\":\""${OSM_PBF_URL}"\", \"gtfs.zip\":\""${GTFS_URL}"\"}"

echo
echo
echo

echo "1 CREATING BUILD DIRECTORY IF NECESSARY"
mkdir -p ${BUILD_DIRECTORY_ABS}
cd ${BUILD_DIRECTORY_ABS}

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
time java -server -Xmx${RAM_GB}G -jar ${OTP_JAR_ABS} --skipVisibility --longDistance --build .

echo "7 GO BACK TO WHERE WE CAME FROM"
cd ${__DIR__}

exit



# TODO:

# USE TIMESTAMPS TO ONLY DOWNLOAD IF NECESSARY
# Checking for existence of properties
# Use named variables