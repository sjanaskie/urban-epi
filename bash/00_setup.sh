#!/bin/bash

###########################################################################
#
# AUTHOR(S):    Ryan Thomas, Yale University
#               
# PURPOSE:      This script runs commands to download data and set up a 
#		GRASS70 database used to calculate the Urban Environmental
#		Assessent Tool.
# 
#############################################################################


export DIR=$(echo $PWD)
echo "You must run this from the 'parent', currently set to $DIR. Do you want to continue?    y/n"

read start
if [ ! "$start" = "y" ]; then
    exit 0
fi

echo "Skipping to $1"

export DATA=${DIR}/data/
export IND=${DIR}/indicators
export SH=${DIR}/source/bash/
export GRASSDB=${DIR}/grassdb/
export RAS=${DIR}/data/raster    # all and only raster data goes here
export VEC=${DIR}/data/vector    # all and only vector data goes here.
export TMP=${DIR}/data/tmp/      # used to download and unzip files.

echo "Exporting variables done."

if [ "$1" = "-dir" ]; then

mkdir -p $DATA
mkdir -p $IND
mkdir -p $SH
mkdir -p $GRASSDB
mkdir -p $RAS 
mkdir -p $VEC 
mkdir -p $TMP 
echo "Directory tree created."


echo ---------------------------------------------------------
echo "Finished creating directories!
If you wish to download the data run: ./00_setup.sh -data
"
echo ---------------------------------------------------------
exit 0


#######################################################################
#
# DOWNLOAD 
#
echo "Would you like to continue to DOWNLOAD the data?"
read dl
#######################################################################
elif [ "$1" = "-data" ] || [ "$dl" = "y" ]; then

echo ------------------------------------------------------------------------------
echo "Running download script. This will take a while. Why don't you grab a coffee in the Agora?"
echo ------------------------------------------------------------------------------
bash 02_download_data.sh
echo
echo "Download compete!"

#######################################################################
#
# BUILD 
#
echo "Would you like to continue to BUILD the database?"
read bd
#######################################################################
elif [ "$1" = "-build" ] || [ "$bd" = "y" ] ; then
    if [ ! "$DIR" = "$PWD" ]; then
        echo "Error: You are not in the home directory, returning to prompt." >> /dev/stderr
        read -p "Press enter to continue."
        echo "Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone."
        read DIR
    fi

echo ---------------------------
echo "building grass"
echo -------------------------


# reproject GHS data from Molleweide
# first make a new location with the data as-is
grass -c -c -e $RAS/population/*.tif population


mkdir -p $VEC/final_cities/ && cp $DIR/source/seed_data/* $VEC/final_cities/

mkdir -p $GRASSDB && cd $GRASSDB
# make vrt to create global location
gdalbuildvrt -overwrite -a_srs "EPSG:4326"  $RAS/glcf/landuse_cover.vrt    $RAS/glcf/*.tif  
gdalbuildvrt -overwrite -a_srs "EPSG:4326"  $RAS/tree_cover/tree_cover.vrt    $RAS/tree_cover/*.tif  


export GRASS_BATCH_JOB="$SH/03_build_grass.sh"

#Blow up previous databse without asking.
rm -rf $GRASSDB/urban
GISDBASE=$GRASSDB/urban
grass -text -c -c $RAS/glcf/landuse_cover.vrt urban $GRASSDB
unset GRASS_BATCH_JOB



#######################################################################
#
# FORM 
#
echo "Would you like to continue to calculate FORM stats?"
read fm
#######################################################################

elif [ "$1" = "-form" ] || [ "$fm" = "y" ]; then
    if [ ! "$DIR" = "$PWD" ]; then
        echo "Error: You are not in the home directory, returning to prompt." >> /dev/stderr
        read -p "Press enter to continue."
        echo "Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone."
        read DIR
    fi
echo ---------------------------
echo "analyzing urban form"
echo -------------------------
# Reading in patch analysis script from bin.
rm -rf ~/.grass7/r.li/output/*
export GRASS_BATCH_JOB="$SH/04_urban_form_analysis.sh"
GISDBASE=$GRASSDB/urban
grass -text -c $GRASSDB/urban/PERMANENT/
unset GRASS_BATCH_JOB


#######################################################################
#
# AIR 
#
echo "Would you like to continue to calculate AIR stats?"
read ar

#######################################################################
elif [ "$1" = "-air" ] || [ "$ar" = "y" ]; then
    if [ ! "$DIR" = "$PWD" ]; then
        echo "Error: You are not in the home directory, returning to prompt." >> /dev/stderr
        read -p "Press enter to continue."
        echo "Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone."
        read DIR
    fi
echo ---------------------------
echo "analyzing air quality"
echo -------------------------
# Reading in patch analysis script from bin.
export GRASS_BATCH_JOB="$SH/05_air_pm25.sh"
GISDBASE=$GRASSDB/urban
grass -text -c $GRASSDB/urban/PERMANENT
unset GRASS_BATCH_JOB



#######################################################################
#
# AIR 
#
echo "Would you like to continue to calculate TRANSPORT stats?"
read tr

#######################################################################
elif [ "$1" = "-trans" ] || [ "$tr" = "y" ]; then
    if [ ! "$DIR" = "$PWD" ]; then
        echo "Error: You are not in the home directory, returning to prompt." >> /dev/stderr
        read -p "Press enter to continue."
        echo "Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone."
        read DIR
    fi
echo ---------------------------
echo "analyzing transportation"
echo -------------------------
# Reading in patch analysis script from bin.
rm -rf $GRASSDB/transportation
export GRASS_BATCH_JOB="$SH/06_transport.sh"
GISDBASE=$GRASSDB/transportation
grass -text  $GRASSDB/urban/PERMANENT
unset GRASS_BATCH_JOB



#######################################################################
#
# AIR 
#
echo "Would you like to continue to calculate GREENSPACE stats?"
read gr

#######################################################################
elif [ "$1" = "-green" ] || [ "$gr" = "y" ]; then
    if [ ! "$DIR" = "$PWD" ]; then
        echo "Error: You are not in the home directory, returning to prompt." >> /dev/stderr
        read -p "Press enter to continue."
        echo "Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone."
        read DIR
    fi
echo ---------------------------
echo "analyzing greenspace"
echo -------------------------
# Reading in patch analysis script from bin.
rm -rf $GRASSDB/transportation
export GRASS_BATCH_JOB="$SH/07_greenspace.sh"
GISDBASE=$GRASSDB/transportation
grass -text  $GRASSDB/urban/PERMANENT
unset GRASS_BATCH_JOB

fi

