#!/bin/bash

###########################################################################
#
# AUTHOR(S):    Ryan Thomas, Yale University
#               
# PURPOSE:      This script builds a grass database with the data downloaded
#               in the previous step.
# 
#############################################################################

g.extension extension=v.in.osm

#Land Coverhttp://wiki.openstreetmap.org/wiki/OSM_file_formats

########################cd ..
##############################################
#r.in.gdal for all global rasters to PERMANENT mapset. 
#r.in.gdal     input=raw/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif   output=pop_density_2015
#r.in.gdal     input=raw/Hansen_GFC2015_gain_00N_080W.tif   output=tree_gain
#r.in.gdal     input=raw/Hansen_GFC2015_loss_00N_080W.tif   output=quito_tree_losss
r.external     input=$RAS/glcf/landuse_cover.vrt     output=landuse --overwrite
r.external     input=$RAS/pm25/GlobalGWR_PM25_GL_201401_201412-RH35_NoDust_NoSalt-NoNegs.asc output=air_pm25_2014 --overwrite
r.external     input=$RAS/pm25/GlobalGWR_PM25_GL_201501_201512-RH35_NoDust_NoSalt-NoNegs.asc output=air_pm25_2015 --overwrite 

exit 0

