

# set mapping region
g.region raster=agglomeration@mexico -p

# read in mexico neighborhoods and overwrite
# NOTE: v.external (as used in previous script) does not bring in attributes.
v.in.ogr ~/projects/urban_epi/data/vector/carto_cities/mexico/mexico.shp --overwrite

r.mapcalc  "air_meanpm25 = (air_pm25_2015@PERMANENT + air_pm25_2014@PERMANENT) / 2" --overwrite

v.rast.stats mexico raster=air_meanpm25 column_prefix=air  method=average,stddev,percentile, percentile=95

d.correlate map=air_meanpm25,meters_from_large_clumps

d.vect.thematic map=mexico column=air_average algorithm=int \
  nclasses=5 colors=0:195:176,39:255:0,251:253:0,242:127:11,193:126:60 
