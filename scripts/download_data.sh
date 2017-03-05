
# This bash script downloads all data for the Urban EPI from the source, as well as setting up the proper directory structure.

DIR=~/projects/urban-epi

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
cd $TMP
wget http://sedac.ciesin.columbia.edu/downloads/data/gpw-v4/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-2015.zip

unzip -f gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-2015.zip  -d    pop_density 

############################################
# Hansen tree cover loss
#while read URL; do
#  wget $URL
#  done <$DIR/treecover_loss_urls.txt
# Hansen tree cover gain
#while read URL; do
#  wget $URL
#  done <$DIR/treecover_gain_urls.txt

'''
mkdir treecover/ && cd treecover
while read URL; do
  wget $URL
  done <$DIR/treecover/treecover_gain_loss_study_areas.txt

cd ..
#################################################



#################################################################################################
# Download shapefile with urban areas into new directory.
# For now, I am waiting to include this step, bounding boxes defined manually.
#mkdir ../ne_10m_urban_areas && cd ne_10m_urban_areas
#wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_urban_areas.zip
#####################################################
'''



