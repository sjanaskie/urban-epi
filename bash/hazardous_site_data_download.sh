#! /bin/bash

# This bash script downloads all data for the Urban EPI from the source, as well as setting up the proper directory structure.
export DIR=~/Documents/data-driven-yale/urban-epi # SOPHIE you may have to change this.
export SH=$DIR/source/bash
export GRASSDB=$DIR/grassdb
export RAS=$DIR/data/raster    # all and only raster data goes here
export VEC=$DIR/data/vector    # all and only vector data goes here.
export TMP=$DIR/data/tmp       # TODO: is this needed?
export SEED=$DIR/seed_data

rm -rf $TMP && mkdir -p $TMP  # Make a TMP folder to store all downloads

#-------------------------------------------------------
# Get data for hazardous sites

# remove any temp files or previous downloads
rm -rf ${VEC}/hazardous_sites/* # remove contents of greenspaces directory
mkdir -p ${VEC}/hazardous_sites/ # make directory (-p flag means "if not exists")

for file in ${SEED}/*.shp; do # loop through shapefiles in city_boundaries

# Below used for debugging:
#file=/Users/sophiejanaskie/Documents/data-driven-yale/urban-epi/seed_data/delhi.shp
# 1.
# echo $file ; done

#2.
#NAME=$(echo `basename $file` | awk -F "[._]" "{ print $1 }")
#bbox=$(ogrinfo -al $file | grep Extent | sed 's/Extent: //g' | sed 's/(//g' | sed 's/)//g' | sed 's/ - /, /g' | sed 's/, /,/g' | awk -F ',' '{print $1 "," $2 "," $3 "," $4}')
#echo $NAME
#echo $bbox

export NAME=$(echo `basename $file` | awk -F "[._]" "{ print $1 }")
export bbox=$(ogrinfo -al $file | grep Extent | sed 's/Extent: //g' | sed 's/(//g' | sed 's/)//g' | sed 's/ - /, /g' | sed 's/, /,/g' | awk -F ',' '{print $1 "," $2 "," $3 "," $4}')

echo -------------------------------------------------------
echo getting osm hazardous sites for $NAME
echo with bbox: $bbox
echo -------------------------------------------------------

# Read hazardous sites  matching the following key:value pairs.
# helpful documentation: http://blog-en.openalfa.com/how-to-query-openstreetmap-using-the-overpass-api
# NOTE: bounding box is in following order (south,west,north,east)
# First, we write the query to a file.
echo "[out:xml][timeout:900][maxsize:1073741824];((
    node["landuse"="landfill"](${bbox});
    rel["landuse"="landfill"](${bbox});
    way["landuse"="landfill"](${bbox});
    node["amenity"="waste_transfer_station"](${bbox});
    way["amenity"="waste_transfer_station"](${bbox});
    relation["amenity"="waste_transfer_station"](${bbox});
    node["man_made"="wastewater_plant"](${bbox});
    way["man_made"="wastewater_plant"](${bbox});
    relation["man_made"="wastewater_plant"](${bbox});
    node["power"="generator"]["generator:source"="waste"](${bbox});
    way["power"="generator"]["generator:source"="waste"](${bbox});
    relation["power"="generator"]["generator:source"="waste"](${bbox});
    node["power"="generator"]["generator:method"="combustion"](${bbox});
    way["power"="generator"]["generator:method"="combustion"](${bbox});
    relation["power"="generator"]["generator:method"="combustion"](${bbox});
    node["landuse"="brownfield"](${bbox});
    way["landuse"="brownfield"](${bbox});
    relation["landuse"="brownfield"](${bbox});
    node["landuse"="industrial"](${bbox});
    way["landuse"="industrial"](${bbox});
    relation["landuse"="industrial"](${bbox});
    node["man_made"="works"]["industrial"="refinery"](${bbox});
    way["man_made"="works"]["industrial"="refinery"](${bbox});
    relation["man_made"="works"]["industrial"="refinery"](${bbox});
    node["power"="generator"]["generator:source"="nuclear"](${bbox});
    way["power"="generator"]["generator:source"="nuclear"](${bbox});
    relation["power"="generator"]["generator:source"="nuclear"](${bbox});
    node["power"="generator"]["generator:method"="fission"](${bbox});
    relation["power"="generator"]["generator:method"="fission"](${bbox});
    way["power"="generator"]["generator:method"="fission"](${bbox});
    node["landuse"="military"]["military"="nuclear_explosion_site"](${bbox});
    way["landuse"="military"]["military"="nuclear_explosion_site"](${bbox});
    relation["landuse"="military"]["military"="nuclear_explosion_site"](${bbox});
    ); out body;
    >;
    out skel qt;" > ${VEC}/hazardous_sites/${NAME}_query.osm # save query to file for debugging/ troubleshooting/ record-keeping

# then use the --post-file option to call in the query, like so:
wget --timeout=0 -O  ${VEC}/hazardous_sites/${NAME}.osm --post-file=${VEC}/hazardous_sites/${NAME}_query.osm "http://overpass-api.de/api/interpreter"

# OSM files are not simple to coerce into a usable format for GRASS or otherwise.
# This NodeJS library (osmtogeojson) is clutch for this and may be #useful elsewhere.
# If you do not have nodejs installed, this StackOverflow post helps you.
# http://stackoverflow.com/questions/30281057/node-forever-usr-bin-env-node-no-such-file-or-directory
osmtogeojson -m -ndjson ${VEC}/hazardous_sites/${NAME}.osm > ${VEC}/hazardous_sites/${NAME}.geojson # Magically converts osm files to GeoJSON.

# convert the vector file old.shp to a raster file new.tif using a pixel size of XRES/YRES
gdal_rasterize -tr .00001 .00001 -burn 255 -ot Byte -co COMPRESS=DEFLATE ${VEC}/hazardous_sites/${NAME}.geojson ${VEC}/hazardous_sites/${NAME}.tif
# convert the raster file new.tif to a vector file new.shp, using the same raster as a -mask speeds up the processing
gdal_polygonize.py -f 'ESRI Shapefile' -mask ${VEC}/hazardous_sites/${NAME}.tif ${VEC}/hazardous_sites/${NAME}.tif ${VEC}/hazardous_sites/${NAME}.shp
# removes the DN attribute created by gdal_polygonize.py
#ogrinfo ${NAME}.shp -sql "ALTER TABLE ${NAME} DROP COLUMN DN"
rm -f ${VEC}/${NAME}.tif
# It *may* be possible to completely flatten the osm file without this.
#ogr2ogr -f GeoJSON ${VEC}/greenspaces/${NAME}_dissolved.geojson ${VEC}/greenspaces/${NAME}.geojson -dialect sqlite -sql "SELECT ST_Union(geometry) FROM OGRGeoJSON"


done
