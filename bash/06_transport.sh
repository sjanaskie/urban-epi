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

    


