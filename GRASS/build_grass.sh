# This bash script downloads all land cover data fromftp://ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01
# MCD12 is the code for land cover data from NASA.

DIR=~/projects/urban-epi/GRASS/
GRASSDB=~/grassdb/
TMP=~/projects/urban-epi/GRASS/tmp/

#################################################################################
# Download all the files

#rm -rf $TMP && mkdir $TMP && cd $TMP
#wget -r ftp://ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01/* 
#cd $DIR

# Gather them into one folder called 'gclf'

#rm -rf $TMP/glcf && mkdir $TMP/glcf
#cp $TMP/ftp.glcf.umd.edu/glcf/Global_LNDCVR/UMD_TILES/Version_5.1/2012.01.01/MCD12Q1_V51_LC1.2012*/*.tif.gz $TMP/glcf

# Unzip them from .gz format.

#cd $TMP/glcf && find . -name '*.gz' -exec gunzip '{}' \;
#cd $DIR

# Uncomment the above lines to download the files again.
#################################################################################################

# Download shapefile with urban areas into new directory.
# For now, I am waiting to include this step, bounding boxes defined manually.
#mkdir ../ne_10m_urban_areas && cd ne_10m_urban_areas
#wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_urban_areas.zip



#####################################################
# Here begins the GRASS database setup.

# First, if you want to start over:
cd $DIR && rm -rf $GRASSDB 

# Creat a vrt from all the tifs
gdalbuildvrt -te -79.5 -1 -77.5 1 -overwrite $TMP/output.vrt $TMP/glcf/*.tif

# Use gdal to make a tif of the study area- in this case, Quito.
gdal_translate -of GTIFF  $TMP/output.vrt  $TMP/quito.tif

# Create a new geoTIFF using a bounding box and the VRT.
# To automate this in the future, create separate tiffs from the VRT in the 
# above line using an input shapefile.
mkdir $GRASSDB && cd $GRASSDB
cp $TMP/quito.tif $GRASSDB/quito.tif


# Write out the projection of the study area
gdalwarp  -t_srs EPSG:4326  -s_srs EPSG:4326  quito.tif quito_proj.tif

# make a new location
rm -rf $GRASSDB/quito 
grass70 -text  -c  -c    quito_proj.tif    quito    $GRASSDB
g.extension r.area


# first rename everything into urban/not urban.
# urban land use is categorized as 13. Anything above or below
# 13 is recoded to 0, urban (13) is recoded to 1

#gdal_calc.py -A C:temp\raster.tif --outfile=result.tiff --calc="0*(A<3)" --calc="1*(A>3)"


r.in.gdal     input=quito.tif     output=quito

r.reclass   input=quito    output=quito_urban   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF



# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=quito_urban   output=urban_lc



#calculate the area of each clump
r.area input=urban_lc  output=quito_lg_clumps   --overwrite   lesser=8 #what is right threshold?


r.report urban_lc units=h


r.li.padrange input=quito_lg_clumps config=biggest_patch output=parent_patch --overwrite
#r.li.patchnum input=name config=name output=name [--overwrite] [--help] [--verbose] [--quiet] [--ui] 

#assign clumps with area > 4km^2 to 1, the rest to 0

#Make a buffer of 20000 m
r.grow.distance -m   input=quito_lg_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#r.grow.distance [-mn] input=name [distance=name] [value=name] [metric=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 

#intersect the quito_urban file with the buffered tif


#if the area is bigger than 2 km sq,
r.reclass   input=meters_from_urban_area   output=quito_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF




#GHSL JRC

#grass
#r.grow.distance in grass


#Global human settlements layer







