#######################################################################
###                HO CHI MINH CITY                                 ###
#######################################################################
DIR=~/projects/urban-epi/GRASS/
GRASSDB=~/grassdb/
TMP=~/projects/urban-epi/GRASS/tmp/
OSMNX=~/projects/urban-epi/scripts/osmnx/data/

#r.in.gdal for all global rasters

# These go in permanent. Global data sets get read in like this.
r.in.gdal     input=landuse_cover.vrt     output=land_cover
r.in.gdal     input=gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif   output=pop_density_2015



# Create new MAPSET and enter into the mapset
g.mapset -c mapset=new_haven

#g.region set each city to a region
# this up in a loop for each city
# for (region in shapefile g.region=region)

v.in.ogr -ewo input=$OSMNX/new_haven_buff/new_haven_buff.shp



g.region  vector=new_haven_buff --o  # region=new_haven
#Quito
#Tokyo
#...

r.reclass   input=land_cover    output=urban_landcover   --overwrite rules=- << EOF
13  = 0 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_landcover   output=urban_landcover_clumps

#calculate the area of each clump
r.area input=urban_landcover_clumps  output=large_urban_clumps   --overwrite   lesser=8 #what is right threshold?

# assign clumps with area > 4km^2 to 1, the rest to 0
# Make a buffer of 20000 m
r.grow.distance -m   input=large_urban_clumps     distance=meters_from_urban_area  metric=geodesic    --overwrite
#if the area is bigger than 2 km sq,
r.reclass   input=meters_from_urban_area   output=urban_agglomeration --overwrite rules=- << EOF
0 thru 2000 = 1 urban
*   = NULL
EOF

# clump the contiguous land uses together with the diagonals included.
r.clump   -d   --overwrite   input=urban_agglomeration   output=urban_agglomeration
BIG=$(r.report -n urban_agglomeration units=c sort=asc | awk -F "|" '{ print $2 }' | tail -n 4 | head -n 1)

#intersect the quito_urban file with the buffered tif
r.mapcalc  "urban_mask = if(urban_agglomeration==$BIG,1,null())" --overwrite
d.mon wx0
d.rast urban_mask
d.mon wx0
d.rast urban_landcover

### Improvement: instead of mask, select all intersecting clumps and grab them.
r.mask raster=urban_mask
r.mapcalc "agglomeration_clumps = urban_lc" --overwrite
r.reclass   input=agglomeration_clumps   output=urban_agglomeration   --overwrite rules=- << EOF
* = 1 urban
EOF
r.mask -r
d.mon wx0
d.rast urban_agglomeration

r.to.vect -s input=urban_agglomeration  output=urban_agglomeration type=area

r.li.patchnum input=urban_agglomeration config=urban_patches output=patch_index --overwrite 
N= ($(awk -F "|"  '{ print $2 }' ~/.grass7/r.li/output/patch_index ))

# assign L to be a vector of all areas
L=$(r.report -n urban_agglomeration units=k | awk -F "|" '{ print $4 }' | tail -n 23)


r.to.vect -s input=agglomeration_clumps  output=urban_area type=area



