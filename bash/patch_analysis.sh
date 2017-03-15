#! /bin/bash

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

# export GRASSDB=$DIR/grassdb

NAME=$(echo `basename $1` | awk -F '.' '{ print $1 }')
BOUNDS=$(ogrinfo -al  $1  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )

echo "
#################################
Working on city:    $NAME       
with bounds:        $BOUNDS     
#################################
"

g.mapset -c  mapset=$NAME location=urban dbase=$GRASSDB 

v.external  $1 layer=$NAME --overwrite
g.region  $BOUNDS --overwrite 

r.external     input=$RAS/glcf/landuse_cover.vrt     output=land_cover@$NAME --overwrite 
r.reclass   input=land_cover@$NAME    output=urban@$NAME   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d  --overwrite   input=urban@$NAME   output=all_clumps@$NAME --quiet

###########################################################################
# Steps to mak the mask

# 1. Select the big clumps
# assign clumps with area > 4km^2 to 1, the rest to 0
r.area input=all_clumps@$NAME  output=large_clumps@$NAME   --overwrite   lesser=8 --quiet   
# TODO: Is 8 right threshold? 

# 2. Make a buffer of 20000 m
r.grow.distance -m  input=large_clumps@$NAME distance=meters_from_large_clumps@$NAME  metric=geodesic --quiet --overwrite
r.reclass   input=meters_from_large_clumps@$NAME   output=buffer@$NAME --overwrite --quiet rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# 3. Clump the buffered urban land uses.
r.clump -d --overwrite input=buffer@$NAME   output=extended_urban_area@$NAME --quiet
# Select the biggest clump as the central urban area.
BIG=$(r.report -n extended_urban_area@$NAME  units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)
r.mapcalc  "buffer = if(extended_urban_area==$BIG,1,null())" --overwrite --quiet

# 4. Calculate the urban areas including partial intersections.
# -c uses circular neighbors; add 0 values to 
r.neighbors -c input=buffer@$NAME selection=all_clumps@$NAME    output=buffer_mask@$NAME  method=stddev size=7 --overwrite --quiet
r.mask      raster=buffer_mask@$NAME --quiet
r.mapcalc   "urban_agglomeration = all_clumps" --overwrite --quiet
r.mask -r

# Reclassify all areas with STDEV of 0 or 1 to be part of the urban agglomeration.
r.reclass    input=extended_urban_area@$NAME   output=urban_agglomeration@$NAME --overwrite --quiet rules=- << EOF
* = 1 urban
EOF
    

r.li.padcv          input=urban_agglomeration@$NAME config=patch_index       output=padcv_$NAME         --overwrite --quiet
r.li.patchdensity   input=urban_agglomeration@$NAME config=patch_index       output=patchdensity_$NAME  --overwrite --quiet
r.li.mps            input=urban_agglomeration@$NAME config=patch_index       output=mps_$NAME          --overwrite --quiet
r.li.edgedensity    input=urban_agglomeration@$NAME config=patch_index       output=edgedensity_$NAME  --overwrite --quiet
r.li.padsd          input=urban_agglomeration@$NAME config=patch_index       output=padsd_$NAME       --overwrite  --quiet
r.li.patchnum       input=urban_agglomeration@$NAME config=patch_index       output=patchnum_$NAME    --overwrite  --quiet
r.li.padrange       input=urban_agglomeration@$NAME config=patch_index       output=padrange_$NAME     --overwrite --quiet

