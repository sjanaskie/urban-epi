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

# Get city shape files using python osmnx
python source/python/get_city_shapes.py


## Population density from University of Columbia's SEDAC, CEISN.
#cd $TMP
#wget http://sedac.ciesin.columbia.edu/downloads/data/gpw-v4/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-2015.zip

#unzip -f gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-2015.zip  -d    pop_density 


#----------------------------------
rm -rf ${VEC}/greenspaces/*
mkdir -p ${VEC}/greenspaces/
for file in ${VEC}/city_boundaries/*.shp; do
export NAME=$(echo `basename $file` | awk -F '[._]' '{ print $1 }')
export bbox=$(ogrinfo -al $file  | grep "Extent: " | awk -F "[ (,)]" '{ print ($5+.1","$3-.1","$11-.1","$9+.1) }' )

# helpful: http://blog-en.openalfa.com/how-to-query-openstreetmap-using-the-overpass-api
# (south,west,north,east)
# uery part for: “amenity=post_box” s e n w
echo -------------------------------------------------------
echo getting osm greenspaces for $NAME
echo with bbox: $bbox
echo -------------------------------------------------------

echo "[out:xml][timeout:900][maxsize:1073741824];((
    rel["leisure"="park"](${bbox});
    way["leisure"="park"](${bbox});
    rel["leisure"="garden"](${bbox});
    way["leisure"="garden"](${bbox});
    rel["leisure"="pitch"](${bbox});
    way["leisure"="pitch"](${bbox});
    rel["leisure"="golf_course"](${bbox});
    way["leisure"="golf_course"](${bbox});
    rel["leisure"="playground"](${bbox});
    way["leisure"="playground"](${bbox});
    rel["leisure"="nature_reserve"](${bbox});
    way["leisure"="nature_reserve"](${bbox});
    rel["amenity"="grave_yard"](${bbox});
    way["amenity"="grave_yard"](${bbox});
    rel["landuse"="cemetery"](${bbox});
    way["landuse"="cemetery"](${bbox});
    rel["landuse"="forest"](${bbox});
    way["landuse"="forest"](${bbox});
    rel["landuse"="meadow"](${bbox});
    way["landuse"="meadow"](${bbox});
    rel["natural"="scrub"](${bbox});
    way["natural"="scrub"](${bbox});
    rel["natural"="wood"](${bbox});
    way["natural"="wood"](${bbox});
    rel["natural"="heath"](${bbox});
    way["natural"="heath"](${bbox});
    rel["boundary"="national_park"](${bbox});
    way["boundary"="national_park"](${bbox}););
  >;); out body;" >${VEC}/greenspaces/${NAME}_query.osm
wget -O  ${VEC}/greenspaces/${NAME}.osm --post-file=${VEC}/greenspaces/${NAME}_query.osm "http://overpass-api.de/api/interpreter";
# If you do not have nodejs installed, this StackOverflow post helps you.
# http://stackoverflow.com/questions/30281057/node-forever-usr-bin-env-node-no-such-file-or-directory
osmtogeojson ${VEC}/greenspaces/${NAME}.osm > ${NAME}.geojson
done
