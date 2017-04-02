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
export DIR=$(echo $PWD)
export DATA=${DIR}/data/
export IND=${DIR}/indicators/
export SH=${DIR}/source/bash/
export GRASSDB=${DIR}/grassdb/
export RAS=${DIR}/data/raster/    # all and only raster data goes here
export VEC=${DIR}/data/vector/  # all and only vector data goes here.
export TMP=${DIR}/data/tmp/      # used to download and unzip files.


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
    bash ${SH}transport.sh $net ; done
