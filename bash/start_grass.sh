#!/bin/bash

grass -text  -c  -c   $RAS/glcf/landuse_cover.vrt urban_environmental_assessment  $GRASSDB
g.extension r.area  #add r.area extension to grass7
