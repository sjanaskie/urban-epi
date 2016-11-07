
# make new variable to use the current directory
DIR=./air_files

rm -rf $DIR # remove previous attempts
mkdir $DIR # remake the directory
cd $DIR # move into the new directory

# make two array variables with the months and elements
declare -a month=("Enero" "Febrero" "Marzo" "Abril" "Mayo" "Junio" "Julio" "Agosto" "Septiembre" "Octubre" "Noviembre" "Diciembre")
declare -a element=("SO2" "CO" "PM%202.5" "O3")

# loop through the year
for ANO in {2008..2015} 
	do echo '#######################'
	# loop through the month
	for MON in "${month[@]}"
		do echo $ANO $MON
			# loop through the elements
			for ELE in "${element[@]}"
			# rename the files by year, month, and element instead of month, year, element
			do wget -O $ANO'_'$MON'_'$ELE'.txt' 'http://redmonitoreo.quitoambiente.gob.ec/file/'$MON$ANO$ELE'.CSV'
		done
	done
done
