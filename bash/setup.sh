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

# Setup directories
if [ "$1" = "-dir" ]; then

echo "
Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone."

read DIR

    if [ ! -d "$DIR" ]; then
    echo "Error: '$DIR' is not a directory, returning to prompt." >> /dev/stderr
    read -p "Press enter to continue."
    echo "Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone."
        read DIR

    fi

# Top level directories. These don't exist yet.
export DATA=$DIR/data/
export IND=$DIR/indicators
mkdir -p $DATA # make new directories
mkdir -p $IND 

# Location of bash scripts
export SH=$DIR/source/bash/

# Grass DB directories
export GRASSDB=$DIR/grassdb/

# Raw data directories
export RAS=$DIR/data/raster    # all and only raster data goes here
export VEC=$DIR/data/vector    # all and only vector data goes here.
export TMP=$DIR/data/tmp/      # used to download and unzip files.
echo ---------------------------------------------------------
echo "Finished creating directories!
If you wish to download the data run: ./setup.sh -data
"
echo ---------------------------------------------------------
exit 0

elif [ "$1" = "-data" ]; then
    if [ ! "$DIR" = "$PWD" ]; then
        echo "Error: '$DIR' is not a directory, returning to prompt." >> /dev/stderr
        read -p "Press enter to continue."
        echo "Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone."
        read DIR
    fi
echo ---------------------------
echo "downloading data dialogue"
echo -------------------------
echo "exporting variables - "
export DATA=$DIR/data/
export IND=$DIR/indicators
export SH=$DIR/source/bash/
export GRASSDB=$DIR/grassdb/
export RAS=$DIR/data/raster    # all and only raster data goes here
export VEC=$DIR/data/vector    # all and only vector data goes here.
export TMP=$DIR/data/tmp/      # used to download and unzip files.
   

echo ------------------------------------------------------------------------------
echo "Running download script. This will take a while. Why don't you grab a coffee?"
echo ------------------------------------------------------------------------------
bash download_data.sh
echo
echo "Download compete!"

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
export DATA=$DIR/data        # 1
export IND=$DIR/indicators    # 2
export SH=$DIR/source/bash    # 3
export GRASSDB=$DIR/grassdb   # 4
export RAS=$DIR/data/raster    # 5 all and only raster data goes here
export VEC=$DIR/data/vector    # 6 all and only vector data goes here.
export TMP=$DIR/data/tmp      # 7 used to download and unzip files.

bash $SH/build_grass.sh

fi



