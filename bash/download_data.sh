#! /bin/bash

# This bash script downloads all data for the Urban EPI from the source, as well as setting up the proper directory structure.
export DIR=~/projects/urban_epi
export SH=$DIR/source/bash    # 3
export GRASSDB=$DIR/grassdb   # 4
export RAS=$DIR/data/raster    # 5 all and only raster data goes here
export VEC=$DIR/data/vector    # 6 all and only vector data goes here.
export TMP=$DIR/data/tmp 


rm -rf $TMP && mkdir -p $TMP                                                # Make a TMP folder to store all downloads

# Land cover data from: ftp://ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01
# MCD12 is the code for land cover data from NASA.z
cd $TMP && wget -r ftp://ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01/*   # Download files into TMP (working dir)
mkdir $RAS/glcf/ && mv $TMP/*/*/*/*/*/*/*/*.tif.gz  $RAS/glcf  # MOVE files from TMP to RAW/glcf 
cd $RAS/glcf && find . -name '*.gz' -exec gunzip '{}' \;                # Unzip them from .gz format.
cd $DIR 


# Protected Planet dot Net files used for biodiversity.
cd $TMP && wget http://wcmc.io/wdpa_current_release  # Move into TMP; Download protected planet files



## Population density from University of Columbia's SEDAC, CEISN.
#cd $TMP
#wget http://sedac.ciesin.columbia.edu/downloads/data/gpw-v4/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-2015.zip

#unzip -f gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-2015.zip  -d    pop_density 
