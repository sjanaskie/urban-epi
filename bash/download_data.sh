
# This bash script downloads all data for the Urban EPI from the source, as well as setting up the proper directory structure.

DIR=~/projects/urban_epi

GRASSDB=~/grassdb/
RAW=~/grassdb/raw/
TMP=$RAW/tmp/

rm -rf $TMP && mkdir -p $TMP                                                # Make a TMP folder to store all downloads

# Land cover data from: ftp://ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01
# MCD12 is the code for land cover data from NASA.
cd $TMP && wget -r ftp://ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01/*   # Download files into TMP (working dir)
mkdir $RAW/glcf/ && mv $TMP/*/*/*/*/*/*/*/*.tif.gz  $RAW/glcf  # MOVE files from TMP to RAW/glcf 
cd $RAW/glcf && find . -name '*.gz' -exec gunzip '{}' \;                # Unzip them from .gz format.
cd $DIR 


# Protected Planet dot Net files used for biodiversity.
cd $TMP && wget http://wcmc.io/wdpa_current_release  # Move into TMP; Download protected planet files
bash 


## Population density from University of Columbia's SEDAC, CEISN.
#cd $TMP
#wget http://sedac.ciesin.columbia.edu/downloads/data/gpw-v4/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-2015.zip

#unzip -f gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-2015.zip  -d    pop_density 
