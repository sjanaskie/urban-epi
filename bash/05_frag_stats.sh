#! /bin/bash


for file in ~/.grass7/r.li/output/*; do
    val=$(cat $file | awk -F "|" '{ print $2 }') 
    echo `basename $file`"_"$val | awk   -F "_" '{ print $1"   " $2 $3"   " $4 }'
    done
