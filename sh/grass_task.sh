#!/bin/sh
# Author: me, today; copyright: GPL >= 2
# Purpose: Script to set computational region to a raster map
# Usage: d.rast.region rastermap

if [ $# -lt 1 ] ; then
   echo "Parameter not defined. Usage"
   echo "   $0 rastermap"
   exit 1
fi

map=$1
g.message message="Setting computational region to map <$map>"
g.region rast=$map
d.erase
d.rast $map
exit 0

