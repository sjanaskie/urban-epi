#!/bin/bash

###########################################################################
#
# AUTHOR(S):    Ryan Thomas, Yale University
#               
# PURPOSE:      This script builds a grass database with the data downloaded
#               in the previous step.
# 
#############################################################################
export DIR=~/projects/urban_epi
export SH=$DIR/source/bash    # 3
export GRASSDB=$DIR/grassdb   # 4
export RAS=$DIR/data/raster    # 5 all and only raster data goes here
export VEC=$DIR/data/vector    # 6 all and only vector data goes here.
export TMP=$DIR/data/tmp 

mkdir $GRASSDB && cd $GRASSDB
# make vrt to create global location
gdalbuildvrt  -overwrite   $RAS/glcf/landuse_cover.vrt    $RAS/glcf/*.tif                                 #Land Cover
grass70 -text  -c  -c   $RAS/glcf/landuse_cover.vrt urban_environmental_assessment  $GRASSDB
g.extension r.area  #add r.area extension to grass7

######################################################################
#r.in.gdal for all global rasters to PERMANENT mapset. 
#r.in.gdal     input=raw/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif   output=pop_density_2015
#r.in.gdal     input=raw/Hansen_GFC2015_gain_00N_080W.tif   output=tree_gain
#r.in.gdal     input=raw/Hansen_GFC2015_loss_00N_080W.tif   output=quito_tree_losss

#######################################################################
###                START WORKING WITH GRASS DATABASE                ###
#######################################################################

# Reading in patch analysis script from bin.


for city in  $VEC/carto_cities/*/*.shp ; do bash $SH/patch_analysis.sh $city ; done

