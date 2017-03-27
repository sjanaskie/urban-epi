#! /bin/bash

# This file simply calls the grass_patch_statistics file on a folder of shapefiles.
# DIR=$(echo $PWD)
export DATA=${DIR}/data/
export IND=${DIR}/indicators
export SH=${DIR}/source/bash/
export GRASSDB=${DIR}/grassdb/
export RAS=${DIR}/data/raster    # all and only raster data goes here
export VEC=${DIR}/data/vector    # all and only vector data goes here.
export TMP=${DIR}/data/tmp/      # used to download and unzip files.


echo "Calculating patch statistics."


# for city in data/vector/city_boundaries/*.shp ; do 
#     # strip .shp
#     path=$(echo ${city} | awk -F "." '{ print $1 }')
#     echo $path
#     echo ${path}_orig
#     mv -f $city ${path}_orig.shp
#     ogr2ogr -t_srs EPSG:4326  ${path}.shp ${path}_orig.shp -overwrite ;
#     rm -f ${path}_orig.* ; 
#     echo "bash $SH/grass_patch_stats.sh $city" ; done

for city in ${VEC}/city_boundaries/*.shp ; do
    echo $city
    bash $SH/grass_patch_stats.sh $city ; done
   
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

# eog path/plot.png
