# This bash script downloads all land cover data fromftp://ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01
# MCD12 is the code for land cover data from NASA.

DIR=~/projects/urban-epi/GRASS/
TMP=~/projects/urban-epi/GRASS/tmp/
ROADS=~/projects/urban-epi/data/roads

GRASSDB=~/grassdb/
PERM=~/grassdb/uepi/
RAW=~/grassdb/raw_data/

#################################################################################
# Download all the files
bash ./download_data.sh
#################################################################################

#################################################################################
# Here begins the GRASS database setup.

# Optional start over:
#cd   $DIR   &&   rm   -rf  $GRASSDB


# To automate this in the future, create separate tiffs from the VRT in the 
# above line using an input shapefile.
#mkdir $GRASSDB
cd $GRASSDB
mkdir $RAW
# make vrt to create global location
gdalbuildvrt  -overwrite   $RAW/landuse_cover.vrt    $TMP/glcf/*.tif                                 #Land Cover


# Use gdal to make a tif of the landcover layer.
# CORECTION: This is done through g.region below.
#gdal_translate  -of  GTIFF   $TMP/landuse_cover.vrt   $TMP/landuse_cover.tif

# Create location with the full earth cover
grass70 -text  -c  -c   $RAW/landuse_cover.vrt    uepi    $GRASSDB
g.extension r.area  #add r.area extension to grass7

# Read in data to /PERMANENT mapset.

cp $TMP/treecover/Hansen_GFC2015_gain_00N_080W.tif   $RAW/Hansen_GFC2015_gain_00N_080W.tif              # Treecover gain quito
cp $TMP/treecover/Hansen_GFC2015_loss_00N_080W.tif   $RAW/Hansen_GFC2015_loss_00N_080W.tif               # Treecover loss quito
cp $TMP/pop_density/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif;
$RAW/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif   #Population Density


######################################################################
#r.in.gdal for all global rasters

# These go in permanent. Global data sets get read in like this.
r.in.gdal     input=landuse_cover.vrt     output=land_cover
r.in.gdal     input=gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif   output=pop_density_2015
r.in.gdal     input=Hansen_GFC2015_gain_00N_080W.tif   output=quito_tree_gain
r.in.gdal     input=Hansen_GFC2015_loss_00N_080W.tif   output=quito_tree_losss



#######################################################################
###                START WORKING WITH GRASS DATABASE                ###
#######################################################################

# Create new MAPSET and enter into the mapset
g.mapset -c mapset=quito

#g.region set each city to a region
# this up in a loop for each city
# for (region in shapefile g.region=region)
g.region  n=1 s=-1 e=-77 w=-79 --o  # region=quito
#Quito
#Tokyo
#...

r.reclass   input=land_cover    output=quito_urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=quito_urban   output=urban_lc

#calculate the area of each clump
r.area input=urban_lc  output=quito_lg_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=quito_lg_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
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
d.mon wx0
d.rast urban_lc

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.mapcalc "agglomeration_clumps = urban_lc" --overwrite
r.reclass   input=agglomeration_clumps   output=quito_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r
d.mon wx0
d.rast quito_agglomeration

r.to.vect -s input=quito_agglomeration  output=quito_agglomeration type=area

r.li.patchnum input=quito_agglomeration config=urban_patches output=patch_index --overwrite 
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/patch_index ))

# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)


r.to.vect -s input=agglomeration_clumps  output=urban_area type=area



