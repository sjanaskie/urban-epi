##############################################################
##  Save this file where you want to download the air data	##
## This script creates a new folder in that location 		##
## called "air_files" and downloads to the new folder.		##

# NOTE: To re-run the download (in case of file corruption) run the 
# following bash command to access the bin directory with download script.

# bash bin/download.sh 


# make new variable to use the current directory
chmod 777 ./
DIR=../air_files

cd $DIR
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
            if (FNR>1) print substr(FILENAME,0,4)"-"substr(FILENAME,6,3)"-"$1" "$2 ":00\t" b[1]"\t" $3"\t" $4"\t" $5"\t" $6"\t" $7"\t" $8"\t" $9"\t" $10"\t" $11"\t" $12"\t" $13"\t" $14 }
    }' *.txt > ../air_data/temp.tsv

cd ../
awk '{ gsub("Ene", "01");gsub("Feb", "02"); gsub("Mar", "03"); gsub("Abr","04"); gsub("May", "05"); 
gsub("Jun", "06");gsub("Jul", "07"); gsub("Ago", "09"); gsub("Oct", "10"); gsub("Nov", "11"); 
gsub("Dic", "12"); gsub("-1 ","-01 ");gsub("-2 ","-02 ");gsub("-3 ","-03 "); gsub("-4 ","-04 ");
gsub("-5 ","-05 "); gsub("-6 ","-06 "); gsub("-7 ","-07 "); gsub("-8 ","-08 "); gsub("-9 ","-09 ");
gsub(" 0:"," 00:"); gsub(" 1:"," 01:"); gsub(" 2:"," 02:"); gsub(" 3:"," 03:"); gsub(" 4:"," 04:");
gsub(" 5:"," 05:"); gsub(" 6:"," 06:"); gsub(" 7:"," 07:"); gsub(" 8:"," 08:"); gsub(" 9:"," 09:");  print }' air_data/temp.tsv > air_data/air_quality.tsv

rm air_data/temp.tsv

#iconv air_quality.tsv -f iso-8859-1 -t UTF-8 -c | 

#take a look at the tail to make sure the type of reading came through
head air_data/air_quality.tsv 
tail air_data/air_quality.tsv






    
    
    
