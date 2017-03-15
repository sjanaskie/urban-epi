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
r.clump   -d  --overwrite   input=urban@$NAME   output=urban_clumps@$NAME --quiet
#calculate the area of each clump
echo "Urban Clumps"
r.area input=urban_clumps@$NAME  output=large_clumps@$NAME   --overwrite   lesser=8 --quiet  #is 8 right threshold?  
# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m  input=large_clumps@$NAME distance=meters_from_urban_area@$NAME  metric=geodesic --quiet --overwrite
#if the area is bigger than 2 km sq, don't include it in the expansion
r.reclass   input=meters_from_urban_area@$NAME   output=urban_peri@$NAME --overwrite --quiet rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump -d --overwrite input=urban_peri@$NAME   output=urban_peri_clumps@$NAME --quiet
BIG=$(r.report -n urban_peri_clumps@$NAME  units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_peri_clumps==$BIG,1,null())" --overwrite --quiet

# -c uses circular neighbors; add 0 values to 
r.neighbors -c input=urban_mask@$NAME selection=urban_clumps@$NAME    output=urban_nbhd@$NAME  method=stddev size=7 --overwrite --quiet
r.mask      raster=urban_nbhd@$NAME --quiet
r.mapcalc   "urban_agglomeration = urban_clumps" --overwrite --quiet
r.mask -r


r.li.padcv          input=urban_agglomeration@$NAME config=patch_index       output=padcv_$NAME         --overwrite --quiet
r.li.patchdensity   input=urban_agglomeration@$NAME config=patch_index       output=patchdensity_$NAME  --overwrite --quiet
r.li.mps            input=urban_agglomeration@$NAME config=patch_index       output=mps_$NAME          --overwrite --quiet
r.li.edgedensity    input=urban_agglomeration@$NAME config=patch_index       output=edgedensity_$NAME  --overwrite --quiet
r.li.padsd          input=urban_agglomeration@$NAME config=patch_index       output=padsd_$NAME       --overwrite  --quiet
r.li.patchnum       input=urban_agglomeration@$NAME config=patch_index       output=patchnum_$NAME    --overwrite  --quiet
r.li.padrange       input=urban_agglomeration@$NAME config=patch_index       output=padrange_$NAME     --overwrite --quiet

