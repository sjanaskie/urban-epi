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
NAME=$(echo `basename $city` | awk -F '.' '{ print $1 }')
BOUNDS=$(ogrinfo -al  $city  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="$5+2,"s="$11-2, "e="$9+2, "w="$3-2) }' ) #two degree buffer

echo "GISDBASE: /home/user/projects/urban_epi/grassdb"      >  $HOME/.grass7/rc$$
echo "LOCATION_NAME: urban"                                 >> $HOME/.grass7/rc$$
echo "MAPSET: $NAME"                                        >> $HOME/.grass7/rc$$
echo "GUI: text"                                            >> $HOME/.grass7/rc$$
echo "GRASS_GUI: wxpython"                                  >> $HOME/.grass7/rc$$


export GISBASE=/usr/lib/grass70
export PATH=$PATH:$GISBASE/bin:$GISBASE/scripts
export LD_LIBRARY_PATH="$GISBASE/lib"
export GISRC=$HOME/.grass7/rc$$
export GRASS_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export PYTHONPATH="$GISBASE/etc/python:$PYTHONPATH"
export MANPATH=$MANPATH:$GISBASE/man



echo "
#################################
Working on city:    $NAME 
with bounds         $BOUNDS
#################################
"

# set mapping region
g.mapset  ${NAME}
g.region ${BOUNDS}

# NOTE: v.external (as used in previous script) does not bring in attributes.
v.in.ogr ${VEC}/city_boundaries/${NAME}.shp  snap=10e-7  --overwrite

echo "
----------------
v.rast.stats
----------------
"

# r.mapcalc  "air_meanpm25 = (air_pm25_2015@PERMANENT + air_pm25_2014@PERMANENT) / 2" --overwrite
v.rast.stats -c map=${NAME}@${NAME} raster=air_pm25_2015@PERMANENT column_prefix=a  method=minimum,maximum,average,median,stddev
v.rast.stats -c map=${NAME}@${NAME} raster=air_pm25_2014@PERMANENT column_prefix=a  method=minimum,maximum,average,median,stddev
#NOTE: column names cannot be of length > 10.

# options to do stats in grass, we decided to use R
#echo "writing regressions"
#r.regression.line mapx=meters_from_all_clumps@${NAME} mapy=air_pm25_2015@PERMANENT  >> data/stats/air/2015_${NAME}_reg.txt
#r.regression.line mapx=meters_from_all_clumps@${NAME} mapy=air_pm25_2014@PERMANENT  >> data/stats/air/2014_${NAME}_reg.txt
#r.stats.quantile -p base=meters_from_all_clumps_integers@${NAME} cover=air_pm25_2014@PERMANENT quantiles=10 bins=20

echo 
r.mapcalc " meters_from_all_clumps_int = round( meters_from_all_clumps@${NAME}  ) "

mkdir -p ${VEC}/air/
echo "outputting csv"

v.out.ogr -c input=${NAME}@${NAME} layer=${NAME} output=${DATA}stats/air/${NAME}.csv format="CSV"  --overwrite --quiet; 

done


