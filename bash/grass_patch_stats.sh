#! /home/user/projects/urban_epi/source/bash/

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
LOCATION_NAME=urban
NAME=$(echo `basename $1` | awk -F '.' '{ print $1 }')
BOUNDS=$(ogrinfo -al  $1  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )

mkdir -p ~/.grass7/r.li/
echo "SAMPLINGFRAME 0|0|1|1
SAMPLEAREA 0.0|0.0|1.0|1.0" > ~/.grass7/r.li/patch_index



echo "
#################################
Working on city:    $NAME       
with bounds:        $BOUNDS     
#################################
"

# open a mapset and set the region.
g.mapset -c  mapset=$NAME location=urban dbase=$GRASSDB 
g.region  $BOUNDS --overwrite 
g.gisenv


# read in the vector and raster layers
echo "Reading in data."
# Moving this line to 03_build_grass.sh so it comes in once.
# We can call it from there and g.region limits the calculation to the BOUNDS.
# r.external     input=$RAS/glcf/landuse_cover.vrt     output=land_cover@$NAME --overwrite 


r.reclass   input=landuse@PERMANENT    output=urban@$NAME   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d  --overwrite   input=urban@$NAME   output=all_clumps@$NAME --quiet

###########################################################################
# Steps to mak the mask
echo "Setting up urban mask."
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
r.mapcalc  "buffer_mask = if(extended_urban_area==$BIG,1,null())" --overwrite --quiet
r.out.gdal  input=urban_agglomeration output=GTiffs/agglomeration/mexico format=GTiff --overwrite

echo "buffer_mask made, now calculating neighbors"
# 4. Calculate the urban areas including partial intersections.
# -c uses circular neighbors; add 0 values to 
r.neighbors -c input=buffer_mask  selection=all_clumps    output=buffer_mask  method=stddev size=7 --overwrite --quiet

echo "clipping agglomeration by mask"
r.mask      raster=buffer_mask --quiet
r.mapcalc   "agglomeration = all_clumps" --overwrite --quiet
r.mask -r

# Reclassify all areas with STDEV of 0 or 1 to be part of the urban agglomeration.
r.reclass    input=agglomeration   output=urban_agglomeration --overwrite --quiet rules=- << EOF
* = 1 urban
EOF

g.remove -f type=raster,raster,raster,raster name=agglomeration,extended_urban_area,urban,buffer


echo "Running patch stats."
r.li.padcv          input=urban_agglomeration@$NAME config=patch_index       output=padcv_$NAME         --overwrite --quiet
r.li.patchdensity   input=urban_agglomeration@$NAME config=patch_index       output=patchdensity_$NAME  --overwrite --quiet
r.li.mps            input=urban_agglomeration@$NAME config=patch_index       output=mps_$NAME          --overwrite --quiet
r.li.edgedensity    input=urban_agglomeration@$NAME config=patch_index       output=edgedensity_$NAME  --overwrite --quiet
r.li.padsd          input=urban_agglomeration@$NAME config=patch_index       output=padsd_$NAME       --overwrite  --quiet
r.li.patchnum       input=urban_agglomeration@$NAME config=patch_index       output=patchnum_$NAME    --overwrite  --quiet
r.li.padrange       input=urban_agglomeration@$NAME config=patch_index       output=padrange_$NAME     --overwrite --quiet
echo "Patch stats complete."

#v.external  $1 layer=$NAME --overwrite

mkdir -p $DIR/GTiffs/agglomeration
r.out.gdal  input=urban_agglomeration output=GTiffs/agglomeration/$NAME format=GTiff --overwrite

