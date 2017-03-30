#! /bin/bash
###########################################################################
#
# AUTHOR(S):    Ryan Thomas, Yale University
#               
# PURPOSE:      This script allows a number of grass70 functions to be 
#               performed on multiple files in different mapsets.
#               variables:
#               -bounds    bounding box
#               -name      file name
#               -location  GRASS location
# 
#############################################################################
# This file simply calls the grass_patch_statistics file on a folder of shapefiles.
DIR=$(echo $PWD)

export DATA=${DIR}/data/
export IND=${DIR}/indicators
export SH=${DIR}/source/bash/
export GRASSDB=${DIR}/grassdb/
export RAS=${DIR}/data/raster/    # all and only raster data goes here
export VEC=${DIR}/data/vector/  # all and only vector data goes here.
export TMP=${DIR}/data/tmp/      # used to download and unzip files.


echo "Calculating air statistics."

for city in ${VEC}/city_boundaries/*.shp ; do
    
    bash $SH/air_stats.sh $city ; done
   
#mkdir -p $DATA/stats/
#for file in ${VEC}/air**.csv; do
    
#echo `basename $file`"."$val | awk   -F "." '{ print $1","$2","$3}'
#    done > $DATA/stats/air_stats.txt

