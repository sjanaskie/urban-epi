#! /home/user/projects/urban_epi/source/bash/

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


export DIR=$(echo $PWD)
export DATA=${DIR}/data/
export IND=${DIR}/indicators
export SH=${DIR}/source/bash/
export GRASSDB=${DIR}/grassdb/
export RAS=${DIR}/data/raster/    # all and only raster data goes here
export VEC=${DIR}/data/vector/  # all and only vector data goes here.
export TMP=${DIR}/data/tmp/      # used to download and unzip files.


# export GRASSDB=$DIR/grassdb
LOCATION_NAME=urban
# Uncomment to restrict bounds to network extent.
#BOUNDS=$(ogrinfo -al  $net  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="$5+1,"s="$11-1, "e="$9+1, "w="$3-1) }' )


echo "
-------------------------------------------
Working on city:    $NAME    
-------------------------------------------
"

g.mapset mapset=$NAME --quiet
g.region vector=$NAME

echo "Reading in data."
v.in.ogr -t input=$net output=streets        type=point --overwrite
v.in.ogr -t input=$int output=intersections  type=line  --overwrite

echo "calculate stats"
v.vect.stats  points=intersections@${NAME}         areas=${NAME}@${NAME}              count_column=int
mkdir -p $DATA/stats/transportation/
v.report      map=${NAME}@${NAME}       option=area                unit=kilometers > $DATA/stats/transportation/${NAME}.txt
v.kernel      input=intersections@${NAME} output=int_density     radius=0.001           --overwrite
v.vect.stats -c  map=${NAME}                raster=int_density         column_prefix=id  method=average

