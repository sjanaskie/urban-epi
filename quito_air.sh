##############################################################
##  Save this file where you want to download the air data	##
## This script creates a new folder in that location 		##
## called "air_files" and downloads to the new folder.		##

# NOTE: To re-run the download (in case of file corruption) run the 
# following bash command to access the bin directory with download script.

# bash bin/download.sh 


# make new variable to use the current directory
DIR=../air_files

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


cd air_files/
for file in *PM%202.5.txt ; do mv "$file" "${file//%202.5/25}" ; done

#We want to create a new file that has the following columns:
#[Year, Month, Day, Hour, Cotocollao, Carapungo, Belisario, Jipijapa, El Camal, Centro, Guamaní, Tumbaco, Los Chillos, El Condado, #Turubamba, Chillogallo]
#To get this, we will do the following:
#for each file in /air_files and grab the year take the year of the filename


# this prints only the third column of data for each month of 2015 
# key - the split must be done in the same brackets as the writing of the type.
awk ' BEGIN { FS=";" } 
    { if (NR==1) 
        {  print "yyyy.mm.dd.hh\t" "Type\t" "Cotocollao\t" "Carapungo\t" "Belisario\t" "Jipijapa\t" "El Camal\t" "Centro\t" "Guamani\t" "Tumbaco\t" "Los Chillos\t" "El Condado\t" "Turubamba\t" "Chillogallo" } 
        else { split(FILENAME,a,"_"); split(a[3],b,".");
            if (FNR>1) print substr(FILENAME,0,4)"-"substr(FILENAME,6,3)"-"$1"-"$2"\t" b[1]"\t" $3"\t" $4"\t" $5"\t" $6"\t" $7"\t" $8"\t" $9"\t" $10"\t" $11"\t" $12"\t" $13"\t" $14 }
    }' *.txt > air_quality.tsv
#iconv air_quality.tsv -f iso-8859-1 -t UTF-8 -c | 

#take a look at the tail to make sure the type of reading came through
head air_quality.tsv 
tail air_quality.tsv


R

aq <- read.table("air_quality.tsv", header=TRUE, sep="\t")

aq[2800:2900,]
q(save = "ask", status = 0, runLast = TRUE)

EOF





    
    
    