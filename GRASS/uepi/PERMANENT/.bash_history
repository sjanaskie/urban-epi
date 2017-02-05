g.extension --verbose r.area  #add r.area extension to grass7
cp $TMP/treecover/Hansen_GFC2015_gain_00N_080W.tif   $RAW/Hansen_GFC2015_gain_00N_080W.tif              # Treecover gain quito
cp $TMP/treecover/Hansen_GFC2015_loss_00N_080W.tif   $RAW/Hansen_GFC2015_loss_00N_080W.tif               # Treecover loss quito
cp $TMP/pop_density/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif;
$RAW/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif   #Population Density
# Read in data to /PERMANENT mapset.
cp $TMP/treecover/Hansen_GFC2015_gain_00N_080W.tif   $RAW/Hansen_GFC2015_gain_00N_080W.tif              # Treecover gain quito
cp $TMP/treecover/Hansen_GFC2015_loss_00N_080W.tif   $RAW/Hansen_GFC2015_loss_00N_080W.tif               # Treecover loss quito
cp $TMP/pop_density/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif $RAW/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals_2015.tif 
ll $TMP
ll
