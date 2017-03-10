
# This bash script downloads all data for the Urban EPI from the source, as well as setting up the proper directory structure.

DIR=~/projects/urban_epi

GRASSDB=~/grassdb/
RAW=~/grassdb/raw
TMP=$RAW/tmp/

# land cover data fromftp://ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01
# MCD12 is the code for land cover data from NASA.
rm -rf $TMP && mkdir -p $TMP && cd $TMP
wget -r ftp://ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01/* 
# Gather them into one folder called 'gclf'
rm -rf $TMP/glcf && mkdir $TMP/glcf
cp $TMP/ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01/MCD12Q1_V51_LC1.2012*/*.tif.gz $RAW/glcf
rm -rf $TMP/ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01/MCD12Q1_V51_LC1.2012*/*.tif.gz
# Unzip them from .gz format.
cd $TMP/glcf && find . -name '*.gz' -exec gunzip '{}' \;


## Population density from University of Columbia's SEDAC, CEISN.
#cd $TMP
#wget http://sedac.ciesin.columbia.edu/downloads/data/gpw-v4/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-2015.zip

#unzip -f gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-2015.zip  -d    pop_density 
