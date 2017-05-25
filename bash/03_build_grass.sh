#! /bin/bash

#############################################################################
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
# This file simply calls the grass_patch_statistics file on a folder of shapefiles.


source source/bash/01_export_directory_tree.sh

#---------------------------------------------------------------
# START LOOP
for city in ${VEC}/city_boundaries/*.shp ; do
# Create name variable from file
NAME=$(echo `basename $city` | awk -F '.' '{ print $1 }')
# Create bounds variable for g.region
BOUNDS=$(ogrinfo -al -so $city  | grep "Extent: " | awk '{ gsub ("[(),-]";
 print ("n="$5+2,"s="$11-2, "e="$9+2, "w="$3-2) }' )
# create bounds for gdalwarp +2 degree buffer
gwarpBOUNDS=$(ogrinfo -al -so project/urban_epi/data/vector/city_boundaries/london.shp  | grep "Extent: " |  awk  '{ gsub ("[(),-]", ""); print ($2-2" "$3-2" "$4+2" "$5+2) }' ) 

# use the shapefile to create a raster landcover layer with the same extent
# options:
# -tr = destination resolution 
# -te = destination bounding box, created by string manipulation on ogrinfo
# -tap = match destination output grid to destination resolution provided in -tr 
echo "---Writing  $RAS/glcf/landuse_cover_${NAME}.tif"
gdalwarp -tr .004666666667 .0046666666667  -te $gwarpBOUNDS -tap -r average $RAS/glcf/landuse_cover.vrt  $RAS/glcf/landuse_cover_${NAME}.tif -overwrite
echo "---Creating location for $NAME"
echo "---I know $RAS"
source create_location_grass7.0.2-grace2.sh /dev/shm/ $NAME $RAS/glcf/landuse_cover_${NAME}.tif

#------------------------------------------------------
# BEGIN PATCH ANALYSIS
echo "Calculating patch statistics."

echo"
#################################
Working on city:    $NAME      
With extent:        $BOUNDS
#################################
"

# open a mapset and set the region.
g.mapset -c  mapset=$NAME location=urban dbase=$GRASSDB 
g.region  $BOUNDS 
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
# Steps to make the mask
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

g.remove -f type=raster,raster,raster name=extended_urban_area,urban,buffer --quiet

# Make a config file for grass. We determined the text for this configuration through the 
# GUI ahead of time.
mkdir -p ~/.grass7/r.li/
echo "SAMPLINGFRAME 0|0|1|1
SAMPLEAREA 0.0|0.0|1.0|1.0" > ~/.grass7/r.li/patch_index

r.li.padcv          input=urban_agglomeration@$NAME config=patch_index       output=${NAME}.padcv         --overwrite --quiet
r.li.patchdensity   input=urban_agglomeration@$NAME config=patch_index       output=${NAME}.patchdensity  --overwrite --quiet
r.li.mps            input=urban_agglomeration@$NAME config=patch_index       output=${NAME}.mps         --overwrite --quiet
r.li.edgedensity    input=urban_agglomeration@$NAME config=patch_index       output=${NAME}.edgedensity  --overwrite --quiet
r.li.padsd          input=urban_agglomeration@$NAME config=patch_index       output=${NAME}.padsd      --overwrite  --quiet
r.li.patchnum       input=urban_agglomeration@$NAME config=patch_index       output=${NAME}.patchnum    --overwrite  --quiet
r.li.padrange       input=urban_agglomeration@$NAME config=patch_index       output=${NAME}.padrange     --overwrite --quiet
echo "Patch stats complete. Saved to ${NAME}.stat."


mkdir -p $DIR/GTiffs/agglomeration
r.out.gdal  input=urban_agglomeration output=GTiffs/agglomeration/$NAME format=GTiff --overwrite; 
done
   
mkdir -p $DATA/stats/
for file in ~/.grass7/r.li/output/*; do
    val=$(cat $file | awk -F "|" '{ print $2 }') 
    echo `basename $file`"."$val | awk   -F "." '{ print $1","$2","$3}'
    done > $DATA/stats/frag_stats.txt

    
#    R --vanilla --no-readline   -q  <<'EOF'
# INDIR = Sys.getenv(c('INDIR'))

R --vanilla <<EOF
require(dplyr)
require(tidyr)
frag_stats <- read.table("~/projects/urban_epi/data/stats/frag_stats.txt", header = FALSE, sep = ",")
colnames(frag_stats) <- c("stat","city", "value")
frag_stats
frag_stats_wd <- frag_stats %>% spread(stat, value)
postscript("path")  # png("path")
plot(frag_stats_wd)
dev.off()
EOF

; done

# eog path/plot.png
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
# This file simply calls the grass_patch_statistics file on a folder of shapefiles.

DIR=$(echo $PWD)

export DATA=${DIR}/data/
export IND=${DIR}/indicators
export SH=${DIR}/source/bash/
export GRASSDB=${DIR}/grassdb/
export RAS=${DIR}/data/raster/    # all and only raster data goes here
export VEC=${DIR}/data/vector/  # all and only vector data goes here.
export TMP=${DIR}/data/tmp/      # used to download and unzip files.


echo "Calculating air statistics."


for city in ${VEC}/city_boundaries/*.shp ; do
NAME=$(echo `basename $city` | awk -F '.' '{ print $1 }')
BOUNDS=$(ogrinfo -al  $city  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="$5+2,"s="$11-2, "e="$9+2, "w="$3-2) }' ) #two degree buffer

echo "GISDBASE: /home/user/projects/urban_epi/grassdb"      >  $HOME/.grass7/rc$$
echo "LOCATION_NAME: urban"                                 >> $HOME/.grass7/rc$$
echo "MAPSET: $NAME"                                        >> $HOME/.grass7/rc$$
echo "GUI: text"                                            >> $HOME/.grass7/rc$$
echo "GRASS_GUI: wxpython"                                  >> $HOME/.grass7/rc$$


export GISBASE=/usr/lib/grass70
export PATH=$PATH:$GISBASE/bin:$GISBASE/scripts
export LD_LIBRARY_PATH="$GISBASE/lib"
export GISRC=$HOME/.grass7/rc$$
export GRASS_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export PYTHONPATH="$GISBASE/etc/python:$PYTHONPATH"
export MANPATH=$MANPATH:$GISBASE/man



echo "
#################################
Working on city:    $NAME 
with bounds         $BOUNDS
#################################
"

# set mapping region
g.mapset  ${NAME}
g.region ${BOUNDS}

# NOTE: v.external (as used in previous script) does not bring in attributes.
v.in.ogr ${VEC}/city_boundaries/${NAME}.shp  snap=10e-7  --overwrite

echo "
----------------
v.rast.stats
----------------
"

# r.mapcalc  "air_meanpm25 = (air_pm25_2015@PERMANENT + air_pm25_2014@PERMANENT) / 2" --overwrite
v.rast.stats -c map=${NAME}@${NAME} raster=air_pm25_2015@PERMANENT column_prefix=a  method=minimum,maximum,average,median,stddev
v.rast.stats -c map=${NAME}@${NAME} raster=air_pm25_2014@PERMANENT column_prefix=a  method=minimum,maximum,average,median,stddev
#NOTE: column names cannot be of length > 10.

# options to do stats in grass, we decided to use R
#echo "writing regressions"
#r.regression.line mapx=meters_from_all_clumps@${NAME} mapy=air_pm25_2015@PERMANENT  >> data/stats/air/2015_${NAME}_reg.txt
#r.regression.line mapx=meters_from_all_clumps@${NAME} mapy=air_pm25_2014@PERMANENT  >> data/stats/air/2014_${NAME}_reg.txt
#r.stats.quantile -p base=meters_from_all_clumps_integers@${NAME} cover=air_pm25_2014@PERMANENT quantiles=10 bins=20

echo 
r.mapcalc " meters_from_all_clumps_int = round( meters_from_all_clumps@${NAME}  ) "

mkdir -p ${VEC}/air/
echo "outputting csv"

v.out.ogr -c input=${NAME}@${NAME} layer=${NAME} output=${DATA}stats/air/${NAME}.csv format="CSV"  --overwrite --quiet; 

done


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
# This file simply calls the grass_patch_statistics file on a folder of shapefiles.

echo "Calculating transport statistics."

# TODO:should these cities be in a different folder? 
for file in ${VEC}networks/*/edges/*.shp ; do
export NAME=$( echo $file | awk -F '/' '{ print $9 }' )

mkdir -p ${VEC}networks/${NAME}/edges_proj/ &&   rm -rf ${VEC}city_networks/${NAME}/edges_proj/*
mkdir -p ${VEC}networks/${NAME}/nodes_proj/ &&   rm -rf ${VEC}city_networks/${NAME}/nodes_proj/*

ogr2ogr  -t_srs EPSG:4326 ${VEC}networks/${NAME}/edges_proj/edges.shp ${VEC}networks/${NAME}/edges/edges.shp 
ogr2ogr  -t_srs EPSG:4326 ${VEC}networks/${NAME}/nodes_proj/nodes.shp ${VEC}networks/${NAME}/nodes/nodes.shp

export int=${VEC}networks/${NAME}/nodes_proj/nodes.shp
export net=${VEC}networks/${NAME}/edges_proj/edges.shp


echo "
-------------------------------------------
Working on city:    $NAME    
-------------------------------------------
"

#g.mapset mapset=$NAME --quiet
g.region vector=$NAME

echo "Reading in data."
v.in.ogr -t input=$net output=streets        type=point --overwrite
v.in.ogr -t input=$int output=intersections  type=line  --overwrite

echo "calculate stats"
v.vect.stats  points=intersections@${NAME}         areas=${NAME}@${NAME}              count_column=int
mkdir -p $DATA/stats/transportation/
v.report      map=${NAME}@${NAME}       option=area         separator=","       unit=kilometers > $DATA/stats/transportation/${NAME}.txt
v.kernel      input=intersections@${NAME} output=int_density     radius=0.001           --overwrite
v.vect.stats -c  map=${NAME}                raster=int_density         column_prefix=id  method=average; 
done

    


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
# This file simply calls the grass_patch_statistics file on a folder of shapefiles.

DIR=$(echo $PWD)

export DATA=${DIR}/data
export IND=${DIR}/indicators
export SH=${DIR}/source/bash
export GRASSDB=${DIR}/grassdb
export RAS=${DIR}/data/raster   # all and only raster data goes here
export VEC=${DIR}/data/vector  # all and only vector data goes here.
export TMP=${DIR}/data/tmp     # used to download and unzip files.


echo "Calculating greenspace statistics."



LOCATION_NAME=urban
NAME=$(echo `basename $CITY` | awk -F '[._]' '{ print $1 }')
BOUNDS=$(ogrinfo -al  $CITY  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="$5+2,"s="$11-2, "e="$9+2, "w="$3-2) }' )


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
# TODO: Fix projection issue
v.in.ogr ${VEC}/greenspaces/${NAME}.shp  snap=10e-7  output=parks --overwrite
#v.in.ogr ${VEC}/greenspaces/${NAME}_parks.shp  snap=10e-7 output=london_grn --overwrite
v.overlay ainput=parks binput=${NAME} operator="and" output=nbhd_parks snap=.000001 --overwrite 
v.db.addcolumn nbhd_parks col="area DOUBLE PRECISION"  --overwrite 
v.to.db map=nbhd_parks@${NAME} layer=1 qlayer=1 option=area units=meters columns=area  --overwrite 
v.centroids input=nbhd_parks output=park_cent option=add   --overwrite 
v.vect.stats points=nbhd_parks areas=${NAME} type=centroid method=sum count_column="parks" points_column=area stats_column="park_area"   --overwrite 



   
#mkdir -p $DATA/stats/
#for file in ${VEC}/air**.csv; do
    
#echo `basename $file`"."$val | awk   -F "." '{ print $1","$2","$3}'
#    done > $DATA/stats/air_stats.txt

