#! /bin/bash

# This is relative to the directory
# of the git repo, which is in a folder
# called bin. Downloaded data and analyzed
# data goes in sibling directories.

# Absolute path to parent directory
echo "
Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone. 
WARNING: It must end with a slash ('/').
"

read DIR

if [ ! -d "$DIR" ]; then
  echo "Error: '$DIR' is not a directory, returning to prompt." >> /dev/stderr
  read -p "Press enter to continue."
  echo "Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone. 
WARNING: It must end with a slash ('/').
"
    read DIR

fi

# Top level directories. These don't exist yet.
DATA=$DIR/data/
IND=$DIR/indicators
mkdir -p $DATA # make new directories
mkdir -p $IND 

# Location of bash scripts
SH=$DIR/source/bash/

# Grass DB directories
GRASSDB=$DIR/grassdb/

# Raw data directories
RAS=$DIR/data/raster    # all and only raster data goes here
VEC=$DIR/data/vector    # all and only vector data goes here.
TMP=$DIR/data/tmp/      # used to download and unzip files.


echo "Finished creating directories!
"

