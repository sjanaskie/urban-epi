ogr2ogr -f ESRI Shapefile ../London_dis.shp ../London.shp -dialect sqlite -sql select ST_union(ST_buffer(Geometry,0.001)),LAD11NM from London GROUP BY LAD11NM -overwrite
