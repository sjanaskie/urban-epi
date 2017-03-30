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


# export GRASSDB=$DIR/grassdb
LOCATION_NAME=urban
echo In grass: ${NAME}
BOUNDS=$(ogrinfo -al  $1  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5),"s="int($11), "e="int($9), "w="int($3)) }' )


echo "
#################################
Working on city:    $NAME      
With extent:        $BOUNDS
#################################
"
exit 0

# open a mapset and set the region.
g.mapset -c  dbase=$GRASSDB location=transportation   mapset=$NAME 
g.region  $BOUNDS 
g.gisenv

# read in the vector and raster layers
echo "Reading in data."

v.in.ogr input=${VEC}city_networks/${NAME}/edges    layer=edges     output=roads  --o --q 
v.in.ogr input=${VEC}city_networks/${NAME}/nodes     layer=nodes     output=intersections  --o --q 


v.vect.stats -a points=nodes areas=${NAME}@${NAME} count_column=intersections



