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

# INPUT VARIABLES, setting to absolute paths
OTP_JAR="${1:-Undefined}"
BUILD_DIRECTORY="${2:-Undefined}"
GRAPH_PROPERTIES_PATH="${3:-Undefined}"

# OTHER VARIABLES
RAM_GB="21"
OSM_PBF_URL="http://download.geofabrik.de/europe/netherlands-latest.osm.pbf"
GTFS_URL="http://gtfs.plannerstack.com/new/gtfs-nl.zip"
# GTFS_URL="http://gtfs.ovapi.nl/new/gtfs-nl.zip" # ALTERNATIVE

# COMPUTED VARIABLED
OTP_JAR_ABS="${__CURRENT_WORKING_DIR__}/${OTP_JAR}"
BUILD_DIRECTORY_ABS="${__CURRENT_WORKING_DIR__}/${BUILD_DIRECTORY}"
GRAPH_PROPERTIES_PATH_ABS="${__CURRENT_WORKING_DIR__}/${GRAPH_PROPERTIES_PATH}"
GRAPH_PROPERTIES_CONTENT=$(<${GRAPH_PROPERTIES_PATH_ABS})
SOURCES_JSON="{\"osm.pbf\":\""${OSM_PBF_URL}"\", \"gtfs.zip\":\""${GTFS_URL}"\"}"

echo "CREATING BUILD DIRECTORY IF NECESSARY"
mkdir -p ${BUILD_DIRECTORY_ABS}
cd ${BUILD_DIRECTORY_ABS}

echo "CREATING GRAPH FILE"
echo "${GRAPH_PROPERTIES_CONTENT}" >> Graph.properties

echo "DOWNLOADING OPENSTREETMAP DATA"
wget ${OSM_PBF_URL} -O osm.pbf --tries=1 --timeout=600

echo "DOWNLOADING GTFS DATA"
wget ${GTFS_URL} -O gtfs.zip --tries=1 --timeout=600

echo "Backup last build graph"
if [ -f Graph.obj ]
then
    mv Graph.obj Graph.obj.last
fi
if [ -f lastBuildSources.json ]
then
    mv lastBuildSources.json lastBuildSources.json.last
fi

echo "SAVE CURRENT BUILD SOURCES"
echo ${SOURCES_JSON} >> lastBuildSources.json

echo "BUILD GRAPH"
time java -server -Xmx${RAM_GB}G -jar ${OTP_JAR_ABS} --skipVisibility --longDistance --build .

echo "GO BACK TO WHERE WE CAME FROM"
cd ${__DIR__}

exit



# TODO:

# USE TIMESTAMPS TO ONLY DOWNLOAD IF NECESSARY
# Checking for existence of properties