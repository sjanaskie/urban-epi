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

read parent

if [ ! -d "$parent" ]; then
  echo "Error: '$parent' is not a directory, returning to prompt." >> /dev/stderr
  read -p "Press enter to continue."
  echo "Please enter the absolute path to the parent directory. You may start from home directory with '~/'. Hint: This is the directory where you ran git clone. 
WARNING: It must end with a slash ('/').
"
    read parent

fi

DIR=$parent

# Location of bash scripts
SH=$DIR/bin/sh/

# Grass DB directories
GRASSDB=$DIR/grassdb/

# Raw data directories
RAS=$DIR/data/raster
VEC=$DIR/data/vector
TMP=$DIR/data/tmp/


