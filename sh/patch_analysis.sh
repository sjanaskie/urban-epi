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


BOUNDS=$(ogrinfo -al  $1  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )
NAME=$(echo $1 | awk -F "/" '{ print $3 }')
    
echo "
#################################
Working on city:    $NAME       
with bounds:        $BOUNDS     
#################################
"

g.region  $BOUNDS --o
r.reclass   input=land_cover    output=urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban   output=urban_clumps
#calculate the area of each clump
r.area input=urban_clumps  output=large_clumps   --overwrite   lesser=8 #what is right threshold?
# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq, don't include it in the expansion
r.reclass   input=meters_from_urban_area   output=urban_peri --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump -d --overwrite input=urban_peri   output=urban_peri_clumps
BIG=$(r.report -n urban_peri_clumps  units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_peri_clumps==$BIG,1,null())" --overwrite

# -c uses circular neighbors; add 0 values to 
r.neighbors -c input=urban_mask selection=urban_clumps    output=urban_nbhd  method=stddev size=7 --overwrite
r.mask      raster=urban_nbhd
r.mapcalc   "urban_agglomeration = urban_clumps" --overwrite
r.mask -r


r.li.padcv          input=urban_agglomeration conf=patch_index       output=padcv_$name 
r.li.patchdensity   input=urban_agglomeration conf=patch_index       output=patchdensity_$name 
r.li.mps            input=urban_agglomeration conf=patch_index       output=mps_$name 
r.li.edgedensity    input=urban_agglomeration conf=patch_index       output=edgedensity_$name 
r.li.padsd          input=urban_agglomeration conf=patch_index       output=padsd_$name 

r.li.patchnum       input=urban_agglomeration config=patch_index     output=patchnum_$name
r.li.padrange       input=urban_agglomeration config=patch_index     output=padrange_$name