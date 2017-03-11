#!/bin/bash
#bash ../bin/directory_tree.sh

DIR=~/projects/urban_epi/
SH=$DIR/bin/sh/

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

# Reading in patch analysis script from 
for city in $(ls -l raw/carto_cities/*/*.shp); do bash $SH/patch_analysis.sh $city ; done


