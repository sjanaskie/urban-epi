exit 0
for city in  $VEC/carto_cities/*/*.shp ; do bash $SH/patch_analysis.sh $city ; done
kate setup.sh 
exit 0
