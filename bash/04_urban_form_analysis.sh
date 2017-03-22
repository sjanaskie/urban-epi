#! /bin/bash

# This file simply calls the grass_patch_statistics file on a folder of shapefiles.
export DIR=~/projects/urban_epi/
export DATA=$DIR/data/
export IND=$DIR/indicators
export SH=$DIR/source/bash/
export GRASSDB=$DIR/grassdb/
export RAS=$DIR/data/raster    # all and only raster data goes here
export VEC=$DIR/data/vector    # all and only vector data goes here.
export TMP=$DIR/data/tmp/      # used to download and unzip files.


echo "Calculating patch statistics."

for city in  $VEC/final_cities/*.shp ; do bash $SH/grass_patch_stats.sh $city ; done

mkdir -p $DATA/stats/
for file in ~/.grass7/r.li/output/*; do
    val=$(cat $file | awk -F "|" '{ print $2 }') 
    echo `basename $file`"_"$val | awk   -F "_" '{ print $1","$2","$3}'
    done > $DATA/stats/frag_stats.txt


R
require(dplyr)
require(tidyr)
frag_stats <- read.table("~/projects/urban_epi/data/stats/frag_stats.txt", header = FALSE, sep = ",")
colnames(frag_stats) <- c("stat","city", "value")
frag_stats
frag_stats_wd <- frag_stats %>% spread(stat, value)
plot(frag_stats_wd)
q("no")

