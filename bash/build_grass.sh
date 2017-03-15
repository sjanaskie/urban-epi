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
#r.in.gdal for all global rasters to PERMANENT mapset. 
#r.in.gdal     input=raw/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif   output=pop_density_2015
#r.in.gdal     input=raw/Hansen_GFC2015_gain_00N_080W.tif   output=tree_gain
#r.in.gdal     input=raw/Hansen_GFC2015_loss_00N_080W.tif   output=quito_tree_losss

#######################################################################
###                START WORKING WITH GRASS DATABASE                ###
######################################################################

# Reading in patch analysis script from bin.


for city in  $VEC/carto_cities/*/*.shp ; do bash $SH/patch_analysis.sh $city ; done

# now compile the outputs of the r.li scripts from folder below
# /home/user/.grass7/r.li/output/*
