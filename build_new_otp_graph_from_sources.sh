#!/usr/bin/env bash

# Fail correctly on pipes
set -o pipefail
# Exit on error
set -o errexit

# FOR DEBUGGING!
set -o xtrace

# Set variables for current FILE, & DIR
__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

# Exit when using undeclared variables
set -o nounset

#
#
#
# END OF BASH SCRIPT BOILERPLATE http://kvz.io/blog/2013/11/21/bash-best-practices/
#
#
#

# INPUT VARIABLES
OTP_JAR="${1:-Undefined}"
BUILD_DIRECTORY="${2:-Undefined}"
GRAPH_PROPERTIES_PATH="${3:-Undefined}"

# COMPUTED VARIABLED
GRAPH_PROPERTIES_CONTENT=$(<${GRAPH_PROPERTIES_PATH})

# OTHER VARIABLES
RAM_GB = "21"
OSM_PBF_URL = "http://download.geofabrik.de/europe/netherlands-latest.osm.pbf"
GTFS_URL = "http://gtfs.plannerstack.com/new/gtfs-nl.zip"
# ALTERNATIVE http://gtfs.ovapi.nl/new/gtfs-nl.zip

echo "GOING INTO TARGET_DIRECTORY"
cd ${TARGET_DIRECTORY}

echo "CREATING BUILD DIRECTORY IF NECESSARY"
mkdir ${BUILD_DIRECTORY}
cd ${BUILD_DIRECTORY}

echo "CREATING GRAPH FILE"
echo "${GRAPH_PROPERTIES_CONTENT}" >> Graph.properties

echo "DOWNLOADING OPENSTREETMAP DATA"
wget ${OSM_PBF_URL} -P .

echo "DOWNLOADING GTFS DATA"
wget ${GTFS_URL} -P .

echo "BUILD GRAPH"
time java -server -Xmx${RAM_GB}G -jar ${OTP_JAR} -a --transitIndex -l -b .

exit