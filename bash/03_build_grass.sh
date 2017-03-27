#!/bin/bash

###########################################################################
#
# AUTHOR(S):    Ryan Thomas, Yale University
#               
# PURPOSE:      This script builds a grass database with the data downloaded
#               in the previous step.
# 
#############################################################################


#Land Cover

######################################################################
# r.external keeps data in parent/data/raster
r.external     input=$RAS/tree_cover/tree_cover.vrt output=tree_cover --overwrite
r.external     input=raw/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif   output=pop_density_2015 --overwrite
r.external     input=$RAS/glcf/landuse_cover.vrt     output=landuse --overwrite
r.external     input=$RAS/pm25/GlobalGWR_PM25_GL_201401_201412-RH35_NoDust_NoSalt-NoNegs.asc output=air_pm25_2014 --overwrite
r.external     input=$RAS/pm25/GlobalGWR_PM25_GL_201501_201512-RH35_NoDust_NoSalt-NoNegs.asc output=air_pm25_2015 --overwrite

gdalbuildvrt -overwrite -a_srs "EPSG:4326"  $RAS/tree_cover/tree_cover.vrt   $RAS/data/raster/tree_cover/*.tif
r.proj  location=population mapset=PERMANENT input=population   output=population  --overwrite

#######################################################################
###                START WORKING WITH GRASS DATABASE                ###
######################################################################

