#!/bin/sh

###########################################################################
#
# AUTHOR(S):    Ryan Thomas, Yale University
#               
# PURPOSE:      This scriptallows a number of grass70 functions to be 
#               performed on multiple files in different mapsets.
#               variables:
#               -bounds    bounding box
#               -name      file name
#               -location  GRASS location
# 
#############################################################################


usage() {
   cat << EOF
Usage: generate_los.sh [ file ]

-file    path/to/file

EOF
   exit 1
}

for city in $1/*.shp;  do
    echo "Working on $city"
    bash ~/projects/urban_epi/bin/sh/patch_analysis.sh $city; 
    done

    