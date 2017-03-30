#! bin/bash
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

LOCATION_NAME=urban
NAME=$(echo `basename $1` | awk -F '.' '{ print $1 }')
BOUNDS=$(ogrinfo -al  $1  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )

echo "
#################################
Working on city:    $NAME 
with bounds         $BOUNDS
#################################
"

# set mapping region
g.mapset ${NAME}
g.region vector=${NAME}

# NOTE: v.external (as used in previous script) does not bring in attributes.
v.in.ogr ${VEC}/city_boundaries/${NAME}.shp  snap=10e-7  --overwrite

echo "v.rast.stats"
# r.mapcalc  "air_meanpm25 = (air_pm25_2015@PERMANENT + air_pm25_2014@PERMANENT) / 2" --overwrite
v.rast.stats -c map=${NAME}@${NAME} raster=air_pm25_2015@PERMANENT column_prefix=air_2015  method=range,median,stddev
v.rast.stats -c map=${NAME}@${NAME} raster=air_pm25_2014@PERMANENT column_prefix=air_2014  method=range,median,stddev

echo "writing regressions"
#r.regression.line mapx=meters_from_all_clumps@${NAME} mapy=air_pm25_2015@PERMANENT  >> data/stats/air/2015_${NAME}_reg.txt
#r.regression.line mapx=meters_from_all_clumps@${NAME} mapy=air_pm25_2014@PERMANENT  >> data/stats/air/2014_${NAME}_reg.txt

mkdir -p ${VEC}/air/
echo "outputting csv"

v.out.ogr -c input=${NAME}@${NAME} layer=${NAME} output=${DATA}stats/air/${NAME}.csv format="CSV"  --overwrite --quiet

