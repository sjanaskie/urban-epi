#bash ../bin/directory_tree.sh

DIR=~/projects/urban_epi/
SH=$DIR/code_base/bash/

GRASSDB=~/grassdb/
RAW=~/grassdb/raw
TMP=$RAW/tmp/

#################################################################################
# Download all the files
#bash ./download_data.sh
#################################################################################

#################################################################################
# Here begins the GRASS database setup.
cd $GRASSDB
# make vrt to create global location
gdalbuildvrt  -overwrite   $RAW/glcf/landuse_cover.vrt    $RAW/glcf/*.tif                                 #Land Cover
grass70 -text
#grass70 -text  -c  -c   $RAW/glcf/landuse_cover.vrt urban_environmental_assessment $GRASSDB
g.extension r.area  #add r.area extension to grass7

######################################################################
#r.in.gdal for all global rasters to PERMANENT mapset. 
r.external     input=raw/glcf/landuse_cover.vrt     output=land_cover
#r.in.gdal     input=raw/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif   output=pop_density_2015
#r.in.gdal     input=raw/Hansen_GFC2015_gain_00N_080W.tif   output=tree_gain
#r.in.gdal     input=raw/Hansen_GFC2015_loss_00N_080W.tif   output=quito_tree_losss

# All the cities in carto/cities
v.external raw/carto_cities/jakarta layer=jakarta
v.external raw/carto_cities/london layer=london
v.external raw/carto_cities/manila layer=manila
v.external raw/carto_cities/merged layer=merged
v.external raw/carto_cities/mexico layer=mexico
v.external raw/carto_cities/new_delhi layer=new_delhi
v.external raw/carto_cities/new_york layer=new_york
v.external raw/carto_cities/sao_paulo layer=sao_paulo
v.external raw/carto_cities/seoul layer=seoul
v.external raw/carto_cities/tokyo layer=tokyo

#######################################################################
###                START WORKING WITH GRASS DATABASE                ###
#######################################################################

# Create new MAPSET and enter into the mapset
# Jakarta
bounds=$(ogrinfo -al  raw/carto_cities/jakarta  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )
name=jakarta
g.mapset -c  mapset=jakarta     location=urban_environmental_assessment dbase=~/grassdb/
g.region  $bounds --o

r.reclass   input=land_cover    output=urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban   output=urban_lc

#calculate the area of each clump
r.area input=urban_lc  output=large_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq,

r.reclass   input=meters_from_urban_area   output=urban_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_agglomeration   output=urban_agglomeration
BIG=$(r.report -n urban_agglomeration units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_agglomeration==$BIG,1,null())" --overwrite
d.mon wx0
d.rast urban_mask
d.rast urban_lc

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.reclass   input=agglomeration_clumps   output=urban_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r

r.mapcalc "peri_urban = urban_agglomeration "

d.rast          urban_agglomeration

r.li.padcv          input=urban_agglomeration conf=patch_index       output=padcv_$name 
r.li.patchdensity   input=urban_agglomeration conf=patch_index       output=patchdensity_$name 
r.li.mps            input=urban_agglomeration conf=patch_index       output=mps_$name 
r.li.edgedensity    input=urban_agglomeration conf=patch_index       output=edgedensity_$name 
r.li.padsd          input=urban_agglomeration conf=patch_index       output=padsd_$name 

r.li.patchnum   input=urban_agglomeration       config=patch_index  output=patchnum_$name
r.li.padrange   input=urban_agglomeration       config=patch_index  output=padrange_$name
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/$name"_patchnum" ))
# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)
#r.to.vect -s input=agglomeration_clumps  output=urban_area type=area
d.mon -r wx0

######################################################################################################
# London
bounds=$(ogrinfo -al  raw/carto_cities/london  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )
name=london
g.mapset -c  mapset=london     location=urban_environmental_assessment dbase=~/grassdb/
g.region  $bounds --o

r.reclass   input=land_cover    output=urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban   output=urban_lc

#calculate the area of each clump
r.area input=urban_lc  output=large_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq,

r.reclass   input=meters_from_urban_area   output=urban_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_agglomeration   output=urban_agglomeration
BIG=$(r.report -n urban_agglomeration units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_agglomeration==$BIG,1,null())" --overwrite
d.mon wx0
d.rast urban_mask
d.rast urban_lc

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.reclass   input=agglomeration_clumps   output=urban_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r

r.mapcalc "peri_urban = urban_agglomeration "

d.rast          urban_agglomeration

r.li.padcv          input=urban_agglomeration conf=patch_index       output=padcv_$name 
r.li.patchdensity   input=urban_agglomeration conf=patch_index       output=patchdensity_$name 
r.li.mps            input=urban_agglomeration conf=patch_index       output=mps_$name 
r.li.edgedensity    input=urban_agglomeration conf=patch_index       output=edgedensity_$name 
r.li.padsd          input=urban_agglomeration conf=patch_index       output=padsd_$name 

r.li.patchnum   input=urban_agglomeration       config=patch_index  output=patchnum_$name
r.li.padrange   input=urban_agglomeration       config=patch_index  output=padrange_$name
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/$name"_patchnum" ))
# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)
#r.to.vect -s input=agglomeration_clumps  output=urban_area type=area
d.mon -r wx0






######################################################################################################
# manila
bounds=$(ogrinfo -al  raw/carto_cities/manila  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )
name=manila
g.mapset -c  mapset=manila     location=urban_environmental_assessment dbase=~/grassdb/
g.region  $bounds --o

r.reclass   input=land_cover    output=urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban   output=urban_lc

#calculate the area of each clump
r.area input=urban_lc  output=large_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq,

r.reclass   input=meters_from_urban_area   output=urban_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_agglomeration   output=urban_agglomeration
BIG=$(r.report -n urban_agglomeration units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_agglomeration==$BIG,1,null())" --overwrite
d.mon wx0
d.rast urban_mask
d.rast urban_lc

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.reclass   input=agglomeration_clumps   output=urban_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r

r.mapcalc "peri_urban = urban_agglomeration "

d.rast          urban_agglomeration

r.li.padcv          input=urban_agglomeration conf=patch_index       output=padcv_$name 
r.li.patchdensity   input=urban_agglomeration conf=patch_index       output=patchdensity_$name 
r.li.mps            input=urban_agglomeration conf=patch_index       output=mps_$name 
r.li.edgedensity    input=urban_agglomeration conf=patch_index       output=edgedensity_$name 
r.li.padsd          input=urban_agglomeration conf=patch_index       output=padsd_$name 

r.li.patchnum   input=urban_agglomeration       config=patch_index  output=patchnum_$name
r.li.padrange   input=urban_agglomeration       config=patch_index  output=padrange_$name
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/$name"_patchnum" ))
# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)
#r.to.vect -s input=agglomeration_clumps  output=urban_area type=area
d.mon -r wx0



######################################################################################################
# mexico
bounds=$(ogrinfo -al  raw/carto_cities/mexico  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )
name=mexico
g.mapset -c  mapset=mexico     location=urban_environmental_assessment dbase=~/grassdb/
g.region  $bounds --o

r.reclass   input=land_cover    output=urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban   output=urban_lc

#calculate the area of each clump
r.area input=urban_lc  output=large_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq,

r.reclass   input=meters_from_urban_area   output=urban_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_agglomeration   output=urban_agglomeration
BIG=$(r.report -n urban_agglomeration units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_agglomeration==$BIG,1,null())" --overwrite
d.mon wx0
d.rast urban_mask
d.rast urban_lc

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.reclass   input=agglomeration_clumps   output=urban_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r

r.mapcalc "peri_urban = urban_agglomeration "

d.rast          urban_agglomeration

r.li.padcv          input=urban_agglomeration conf=patch_index       output=padcv_$name 
r.li.patchdensity   input=urban_agglomeration conf=patch_index       output=patchdensity_$name 
r.li.mps            input=urban_agglomeration conf=patch_index       output=mps_$name 
r.li.edgedensity    input=urban_agglomeration conf=patch_index       output=edgedensity_$name 
r.li.padsd          input=urban_agglomeration conf=patch_index       output=padsd_$name 

r.li.patchnum   input=urban_agglomeration       config=patch_index  output=patchnum_$name
r.li.padrange   input=urban_agglomeration       config=patch_index  output=padrange_$name
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/$name"_patchnum" ))
# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)
#r.to.vect -s input=agglomeration_clumps  output=urban_area type=area
d.mon -r wx0



# g.mapset -c  mapset=new_delhi   location=urban_environmental_assessment dbase=~/grassdb/
######################################################################################################
# new_delhi
bounds=$(ogrinfo -al  raw/carto_cities/new_delhi  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )
name=new_delhi
g.mapset -c  mapset=new_delhi     location=urban_environmental_assessment dbase=~/grassdb/
g.region  $bounds --o

r.reclass   input=land_cover    output=urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban   output=urban_lc

#calculate the area of each clump
r.area input=urban_lc  output=large_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq,

r.reclass   input=meters_from_urban_area   output=urban_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_agglomeration   output=urban_agglomeration
BIG=$(r.report -n urban_agglomeration units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_agglomeration==$BIG,1,null())" --overwrite
d.mon wx0
d.rast urban_mask
d.rast urban_lc

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.reclass   input=agglomeration_clumps   output=urban_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r

r.mapcalc "peri_urban = urban_agglomeration "

d.rast          urban_agglomeration

r.li.padcv          input=urban_agglomeration conf=patch_index       output=padcv_$name 
r.li.patchdensity   input=urban_agglomeration conf=patch_index       output=patchdensity_$name 
r.li.mps            input=urban_agglomeration conf=patch_index       output=mps_$name 
r.li.edgedensity    input=urban_agglomeration conf=patch_index       output=edgedensity_$name 
r.li.padsd          input=urban_agglomeration conf=patch_index       output=padsd_$name 

r.li.patchnum   input=urban_agglomeration       config=patch_index  output=patchnum_$name
r.li.padrange   input=urban_agglomeration       config=patch_index  output=padrange_$name
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/$name"_patchnum" ))
# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)
#r.to.vect -s input=agglomeration_clumps  output=urban_area type=area
d.mon -r wx0




######################################################################################################
# new_york
bounds=$(ogrinfo -al  raw/carto_cities/new_york  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )
name=new_york
g.mapset -c  mapset=new_york     location=urban_environmental_assessment dbase=~/grassdb/
g.region  $bounds --o

r.reclass   input=land_cover    output=urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban   output=urban_lc

#calculate the area of each clump
r.area input=urban_lc  output=large_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq,

r.reclass   input=meters_from_urban_area   output=urban_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_agglomeration   output=urban_agglomeration
BIG=$(r.report -n urban_agglomeration units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_agglomeration==$BIG,1,null())" --overwrite
d.mon wx0
d.rast urban_mask
d.rast urban_lc

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.reclass   input=agglomeration_clumps   output=urban_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r

r.mapcalc "peri_urban = urban_agglomeration "

d.rast          urban_agglomeration

r.li.padcv          input=urban_agglomeration conf=patch_index       output=padcv_$name 
r.li.patchdensity   input=urban_agglomeration conf=patch_index       output=patchdensity_$name 
r.li.mps            input=urban_agglomeration conf=patch_index       output=mps_$name 
r.li.edgedensity    input=urban_agglomeration conf=patch_index       output=edgedensity_$name 
r.li.padsd          input=urban_agglomeration conf=patch_index       output=padsd_$name 

r.li.patchnum   input=urban_agglomeration       config=patch_index  output=patchnum_$name
r.li.padrange   input=urban_agglomeration       config=patch_index  output=padrange_$name
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/$name"_patchnum" ))
# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)
#r.to.vect -s input=agglomeration_clumps  output=urban_area type=area
d.mon -r wx0





######################################################################################################
# sao_paulo
bounds=$(ogrinfo -al  raw/carto_cities/sao_paulo  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )
name=sao_paulo
g.mapset -c  mapset=sao_paulo     location=urban_environmental_assessment dbase=~/grassdb/
g.region  $bounds --o

r.reclass   input=land_cover    output=urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban   output=urban_lc

#calculate the area of each clump
r.area input=urban_lc  output=large_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq,

r.reclass   input=meters_from_urban_area   output=urban_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_agglomeration   output=urban_agglomeration
BIG=$(r.report -n urban_agglomeration units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_agglomeration==$BIG,1,null())" --overwrite
d.mon wx0
d.rast urban_mask
d.rast urban_lc

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.reclass   input=agglomeration_clumps   output=urban_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r

r.mapcalc "peri_urban = urban_agglomeration "

d.rast          urban_agglomeration

r.li.padcv          input=urban_agglomeration conf=patch_index       output=padcv_$name 
r.li.patchdensity   input=urban_agglomeration conf=patch_index       output=patchdensity_$name 
r.li.mps            input=urban_agglomeration conf=patch_index       output=mps_$name 
r.li.edgedensity    input=urban_agglomeration conf=patch_index       output=edgedensity_$name 
r.li.padsd          input=urban_agglomeration conf=patch_index       output=padsd_$name 

r.li.patchnum   input=urban_agglomeration       config=patch_index  output=patchnum_$name
r.li.padrange   input=urban_agglomeration       config=patch_index  output=padrange_$name
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/$name"_patchnum" ))
# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)
#r.to.vect -s input=agglomeration_clumps  output=urban_area type=area
d.mon -r wx0





# g.mapset -c  mapset=seoul       location=urban_environmental_assessment dbase=~/grassdb/
######################################################################################################
# Seoul
bounds=$(ogrinfo -al  raw/carto_cities/seoul  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )
name=seoul
g.mapset -c  mapset=seoul     location=urban_environmental_assessment dbase=~/grassdb/
g.region  $bounds --o

r.reclass   input=land_cover    output=urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban   output=urban_lc

#calculate the area of each clump
r.area input=urban_lc  output=large_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq,

r.reclass   input=meters_from_urban_area   output=urban_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_agglomeration   output=urban_agglomeration
BIG=$(r.report -n urban_agglomeration units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_agglomeration==$BIG,1,null())" --overwrite
d.mon wx0
d.rast urban_mask
d.rast urban_lc

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.reclass   input=agglomeration_clumps   output=urban_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r

r.mapcalc "peri_urban = urban_agglomeration "

d.rast          urban_agglomeration

r.li.padcv          input=urban_agglomeration conf=patch_index       output=padcv_$name 
r.li.patchdensity   input=urban_agglomeration conf=patch_index       output=patchdensity_$name 
r.li.mps            input=urban_agglomeration conf=patch_index       output=mps_$name 
r.li.edgedensity    input=urban_agglomeration conf=patch_index       output=edgedensity_$name 
r.li.padsd          input=urban_agglomeration conf=patch_index       output=padsd_$name 

r.li.patchnum   input=urban_agglomeration       config=patch_index  output=patchnum_$name
r.li.padrange   input=urban_agglomeration       config=patch_index  output=padrange_$name
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/$name"_patchnum" ))
# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)
#r.to.vect -s input=agglomeration_clumps  output=urban_area type=area
d.mon -r wx0




# g.mapset -c  mapset=tokyo       location=urban_environmental_assessment dbase=~/grassdb/
######################################################################################################
# tokyo
bounds=$(ogrinfo -al  raw/carto_cities/tokyo  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )
name=tokyo
g.mapset -c  mapset=tokyo     location=urban_environmental_assessment dbase=~/grassdb/
g.region  $bounds --o

r.reclass   input=land_cover    output=urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban   output=urban_lc

#calculate the area of each clump
r.area input=urban_lc  output=large_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq,

r.reclass   input=meters_from_urban_area   output=urban_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_agglomeration   output=urban_agglomeration
BIG=$(r.report -n urban_agglomeration units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_agglomeration==$BIG,1,null())" --overwrite
d.mon wx0
d.rast urban_mask
d.rast urban_lc

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.reclass   input=agglomeration_clumps   output=urban_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r

r.mapcalc "peri_urban = urban_agglomeration "

d.rast          urban_agglomeration

r.li.padcv          input=urban_agglomeration conf=patch_index       output=padcv_$name 
r.li.patchdensity   input=urban_agglomeration conf=patch_index       output=patchdensity_$name 
r.li.mps            input=urban_agglomeration conf=patch_index       output=mps_$name 
r.li.edgedensity    input=urban_agglomeration conf=patch_index       output=edgedensity_$name 
r.li.padsd          input=urban_agglomeration conf=patch_index       output=padsd_$name 

r.li.patchnum   input=urban_agglomeration       config=patch_index  output=patchnum_$name
r.li.padrange   input=urban_agglomeration       config=patch_index  output=padrange_$name
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/$name"_patchnum" ))
# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)
#r.to.vect -s input=agglomeration_clumps  output=urban_area type=area
d.mon -r wx0







# g.mapset -c  mapset=quito       location=urban_environmental_assessment dbase=~/grassdb/
######################################################################################################
# quito
bounds=$(ogrinfo -al  raw/carto_cities/quito  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="int($5+2),"s="int($11-2), "e="int($9+2), "w="int($3-2)) }' )
name=quito
echo "now on to $name"

g.mapset -c  mapset=quito     location=urban_environmental_assessment dbase=~/grassdb/
g.region  $bounds --o

r.reclass   input=land_cover    output=urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban   output=urban_lc

#calculate the area of each clump
r.area input=urban_lc  output=large_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq,

r.reclass   input=meters_from_urban_area   output=urban_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_agglomeration   output=urban_agglomeration
BIG=$(r.report -n urban_agglomeration units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_agglomeration==$BIG,1,null())" --overwrite
d.mon wx0
d.rast urban_mask
d.rast urban_lc

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.reclass   input=agglomeration_clumps   output=urban_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r

r.mapcalc "peri_urban = urban_agglomeration "

d.rast          urban_agglomeration

r.li.padcv          input=urban_agglomeration conf=patch_index       output=padcv_$name 
r.li.patchdensity   input=urban_agglomeration conf=patch_index       output=patchdensity_$name 
r.li.mps            input=urban_agglomeration conf=patch_index       output=mps_$name 
r.li.edgedensity    input=urban_agglomeration conf=patch_index       output=edgedensity_$name 
r.li.padsd          input=urban_agglomeration conf=patch_index       output=padsd_$name 

r.li.patchnum   input=urban_agglomeration       config=patch_index  output=patchnum_$name
r.li.padrange   input=urban_agglomeration       config=patch_index  output=padrange_$name
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/$name"_patchnum" ))
# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)
#r.to.vect -s input=agglomeration_clumps  output=urban_area type=area
d.mon -r wx0
