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

export DATA=${DIR}/data
export IND=${DIR}/indicators
export SH=${DIR}/source/bash
export GRASSDB=${DIR}/grassdb
export RAS=${DIR}/data/raster   # all and only raster data goes here
export VEC=${DIR}/data/vector  # all and only vector data goes here.
export TMP=${DIR}/data/tmp     # used to download and unzip files.


echo "Calculating greenspace statistics."



LOCATION_NAME=urban
NAME=$(echo `basename $CITY` | awk -F '[._]' '{ print $1 }')
BOUNDS=$(ogrinfo -al  $CITY  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="$5+2,"s="$11-2, "e="$9+2, "w="$3-2) }' )


echo "
#################################
Working on city:    $NAME 
with bounds         $BOUNDS
#################################
"

# set mapping region
g.mapset -c ${NAME}
g.region vector=${NAME}

# NOTE: v.external (as used in previous script) does not bring in attributes.
# TODO: Fix projection issue
v.in.ogr ${VEC}/greenspaces/${NAME}.shp  snap=10e-7  output=parks --overwrite
#v.in.ogr ${VEC}/greenspaces/${NAME}_parks.shp  snap=10e-7 output=london_grn --overwrite
v.overlay ainput=parks binput=${NAME} operator="and" output=nbhd_parks snap=.000001 --overwrite 
v.db.addcolumn nbhd_parks col="area DOUBLE PRECISION"  --overwrite 
v.to.db map=nbhd_parks@${NAME} layer=1 qlayer=1 option=area units=meters columns=area  --overwrite 
v.centroids input=nbhd_parks output=park_cent option=add   --overwrite 
v.vect.stats points=nbhd_parks areas=${NAME} type=centroid method=sum count_column="parks" points_column=area stats_column="park_area"   --overwrite 



   
#mkdir -p $DATA/stats/
#for file in ${VEC}/air**.csv; do
    
#echo `basename $file`"."$val | awk   -F "." '{ print $1","$2","$3}'
#    done > $DATA/stats/air_stats.txt

