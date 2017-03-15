

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

echo "
Please enter the absolute path to the parent directory starting from root '/'. Hint: This is the directory where you ran git clone."

read DIR

    if [ ! -d "$DIR" ]; then
    echo "Error: '$DIR' is not a directory, returning to prompt." >> /dev/stderr
    read -p "Press enter to continue."
    echo "Please enter the absolute path to the parent directory starting from root '/'. Hint: This is the directory where you ran git clone."
        read DIR

    fi

export DATA=$DIR/data/
export IND=$DIR/indicators
export SH=$DIR/source/bash/
export GRASSDB=$DIR/grassdb/
export RAS=$DIR/data/raster    # all and only raster data goes here
export VEC=$DIR/data/vector    # all and only vector data goes here.
export TMP=$DIR/data/tmp/      # used to download and unzip files.

#################################################################
# Directory Flag
if [ "$1" = "-dir" ]; then

mkdir -p $DATA
mkdir -p $IND
mkdir -p $SH
mkdir -p $GRASSDB
mkdir -p $RAS 
mkdir -p $VEC 
mkdir -p $TMP 


echo ---------------------------------------------------------
echo "Finished creating directories!
If you wish to download the data run: ./setup.sh -data
"
echo ---------------------------------------------------------
exit 0


#################################################################
# Data Flag

elif [ "$1" = "-data" ]; then

echo ------------------------------------------------------------------------------
echo "Running download script. This will take a while. Why don't you grab a coffee at the Agora in Singapore?"
echo ------------------------------------------------------------------------------
bash download_data.sh
echo
echo "Download compete!"

echo "Would you like to build the GRASS databse now?
run source/bash/setup.sh -grass"
exit 0

#################################################################
# Grass Flag

elif [ "$1" = "-grass" ]; then
    if [ ! "$DIR" = "$PWD" ]; then
        echo "Error: You are not in the home directory, returning to prompt." >> /dev/stderr
        read -p "Press enter to continue."
        echo "Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone."
        read DIR
    fi
echo ---------------------------
echo "building grass"
echo -------------------------
echo "exporting variables "


mkdir $GRASSDB && cd $GRASSDB
# make vrt to create global location
gdalbuildvrt  -overwrite   $RAS/glcf/landuse_cover.vrt    $RAS/glcf/*.tif  

export GRASS_BATCH_JOB="$SH/build_grass.sh"

grass $GRASSDB/urban_environmental_assessment/PERMANENT

unset GRASS_BATCH_JOB

fi



