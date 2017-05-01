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
NAME=$(echo `basename $1` | awk -F '[._]' '{ print $1 }')
BOUNDS=$(ogrinfo -al  $1  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="$5+2,"s="$11-2, "e="$9+2, "w="$3-2) }' )

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
v.in.ogr ${VEC}/city_green/${NAME}_treecover.shp  snap=10e-7  --overwrite
v.in.ogr ${VEC}/city_green/${NAME}_parks.shp  snap=10e-7  --overwrite
v.in.osm
v.db.join map=${NAME} column=cat other_table=${NAME}_parks other_column=cat --overwrite
v.db.join map=${NAME} column=cat other_table=${NAME}_treecover other_column=cat --overwrite


mkdir -p ${DATA}stats/greenspace
v.out.ogr -c input=${NAME}@${NAME} layer=${NAME} output=${DATA}stats/greenspace/${NAME}.csv format="CSV"  --overwrite --quiet
mkdir -p ${DATA}/vector/out/
v.out.ogr -c input=${NAME}@${NAME} layer=${NAME} output=${DATA}/vector/out/${NAME}.shp   --overwrite --quiet
