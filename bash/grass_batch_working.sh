for city in $RAW/carto_cities/* ; do 
echo $city
    bounds=$(ogrinfo -al  $city  | grep "Extent: " | awk -F "[ (,)]" '{ print ("n="$11,"s="$5, "e="$9, "w="$3) }' )
    name=$(echo $city | awk -F "/" '{ print $7 }') 
    
    echo "writing file for" $name 
    mkdir -p $TMP/gregions/
    
    echo "export GRASS_MESSAGE_FORMAT=plain
g.region $bounds --o" > $TMP/gregions/$name.sh
    
    cat $TMP/gregions/$name.sh
    chmod u+x $TMP/gregions/$name.sh
    echo LOCATION = ~/grassdb/urban_environmental_assessment/$name
    echo GISDBASE = ~/grassdb/
    echo LOCATION_NAME = urban_environmental_assessment
    echo MAPSET = $name
    grass70 -text 
    export GRASS_BATCH_JOB="$HOME/my_grassjob.sh"
    unset GRASS_BATCH_JOB

    done
