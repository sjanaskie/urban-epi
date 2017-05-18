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

LOCATION_NAME=urban
NAME=$(echo `basename $CITY` | awk -F '.' '{ print $1 }')
BOUNDS=$(ogrinfo -al  $CITY  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="$5+2,"s="$11-2, "e="$9+2, "w="$3-2) }' ) #two degree buffer

echo "
#################################
Working on city:    $NAME 
with bounds         $BOUNDS
#################################
"

# set mapping region
g.mapset -c ${NAME}
g.region ${BOUNDS}

#v.db.addcolumn ${NAME} col="area DOUBLE PRECISION"
#v.to.db map=${NAME}@${NAME} layer=1 qlayer=1 option=area units=meters columns=area

#db.out.ogr  input=${NAME}@${NAME} output=${DATA}stats/final/${NAME}.csv format="CSV"  --overwrite #--quiet
v.report      map=${NAME}@${NAME}     option=area      unit=kilometers > $DATA/stats/final/${NAME}.txt
