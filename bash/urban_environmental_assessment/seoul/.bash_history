g.gui
g.gui
g.gui
exit 0
g.mapset
g.mapset -h
$NAMENAME=$(echo `basename $1` | awk -F '.' '{ print $1 }')
NAME=$(echo `basename $1` | awk -F '.' '{ print $1 }')
exit 0
v.external ../data/vector/carto_cities/jakarta layer=jakarta
v.external  ../data/vector/carto_cities/jakarta/jakarta.shp  layer=jakarta
g.region man
man g.region
g.gui
exit 0
g.gui
