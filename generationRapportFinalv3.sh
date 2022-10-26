#!/bin/bash

pathFile=$HOME

gnuplot --persist -e "set datafile separator '_'; set xdata time; set format x '%H:%M'; set timefmt '%H:%M'; set xrange ['00:00':'24:00']; set xtics '02:00'; set xlabel 'humidite'; set terminal png size 850,300; set  output '$pathFile/temp/outputHumidite.png'; plot '$pathFile/temp/humidite' u 1:2 with lines notitle"
gnuplot --persist -e "set datafile separator '_'; set xdata time; set format x '%H:%M'; set timefmt '%H:%M'; set xrange ['00:00':'24:00']; set xtics '02:00'; set xlabel 'temperatures'; set terminal png size 850,300; set  output '$pathFile/temp/outputTemperature.png'; plot '$pathFile/temp/temperature' u 1:2 with lines notitle"

gnuplot --persist -e "set datafile separator '_'; set xdata time; set format x '%H:%M'; set timefmt '%H:%M';set autoscale xy;X='';IMG='';storedata(x,index_img)=(X=X.sprintf(' %f',int(x)*3600),IMG=IMG.sprintf(' %s',index_img),1);set terminal png size 2000,200;set output '$pathFile/temp/data.png';plot '$pathFile/temp/ciel' using 1:(storedata(column(1),stringcolumn(3)));set xrange ['00:00':'24:00'];set xtics '02:00';unset ytics;set terminal png size 2000,200;set output '$pathFile/temp/outputCiel.png';plot ['00:00':'24:00'][-8:8] for [i=1:words(IMG)] '$pathFile/images/'.word(IMG,i).'.png' binary filetype=png center=(word(X,i),'0') dx=15 dy=0.03 with rgbalpha notitle"



unEmplacementLon=$(awk -F\" '{print $5}' weather.json | sed 's/://g' | sed 's/,//g' | sed 's/}//g' | awk '{ print substr($0,1,1) }')
unEmplacementLat=$(awk -F\" '{print $7}' weather.json | sed 's/://g' | sed 's/,//g' | sed 's/}//g' | awk '{ print substr($0,1,1) }')

if test $unEmplacementLon=="-"
then emplacementLon=$(awk -F\" '{print $5}' weather.json | sed 's/://g' | sed 's/,//g' | sed 's/}//g' | sed 's/-//g')."°W"
else emplacementLon=$(awk -F\" '{print $5}' weather.json | sed 's/://g' | sed 's/,//g' | sed 's/}//g' | sed 's/-//g')."°E"
fi

if test $unEmplacementLat=="-"
then emplacementLat=$(awk -F\" '{print $7}' $pathFile/weather.json | sed 's/://g' | sed 's/,//g' | sed 's/}//g' | sed 's/-//g')."°N"
else emplacementLat=$(awk -F\" '{print $7}' $pathFile/weather.json | sed 's/://g' | sed 's/,//g' | sed 's/}//g' | sed 's/-//g')."°S"
fi
ville=$(awk -F\" '{print $76}' $pathFile/weather.json)
date=$(date +"%d-%m-%Y")
heure=$(date +"%k" | sed "s/ //g")
global=$(awk -F '_' '{print $2}' temp/ciel | sort | uniq -c | sort -rn | awk '{print $2; exit}')

touch $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md


printf -- "---\n" > $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf "header-includes:" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf -- "\n- \\\usepackage{fancyhdr}" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf -- "\n- \\\usepackage{graphicx}" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf -- "\n- \\\usepackage[margin=2.5cm,a4paper]{geometry}" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf -- "\n- \\\pagestyle{fancy}" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf -- "\n- \\\lhead{Rapport météorologique de "$ville"}" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf -- "\n- \\\rhead{$(date +"%d-%m-%Y")}" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf "\noutput: pdf_document" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf -- "\n---\n" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md

printf "# Rapport météorologique de "$ville >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf "\n\n**Jour**: "$date >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf "\n\n**Emplacement**: "$ville" ("$emplacementLat","$emplacementLon")" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md


printf "\n\n## Ciel\n" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md

printf "\n![]($pathFile/temp/outputCiel.png)" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf "\n- **global**: $global" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md

printf "\n\n## Températures\n" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md


let minTemperature=999
let maxTemperature=-999
let moyenneTemperature=0
for (( c=0; c<=$heure; c++ ))
do  
    if [ $(awk -F ":" '{if ($1=='$c'){print $0}}' 'temp/temperature'|awk "END{print NR}") -gt 0 ]
    then
        moyenneTemperature=$(awk -F ":" '{if ($1=='$c'){print $2}}' 'temp/temperature'| awk -F "_" 'BEGIN{sommeTemperature=0} {sommeTemperature+=$2} END{print (sommeTemperature/NR)}')
        testMin=$(awk '{print $1 < $2}' <<< "$moyenneTemperature $minTemperature" )
        testMax=$( awk '{print $1 < $2}' <<< "$maxTemperature $moyenneTemperature" )
        if [ "$testMin" -eq "1" ]
        then
            minTemperature=$moyenneTemperature
        fi
        if [ "$testMax" -eq "1" ]
        then
            maxTemperature=$moyenneTemperature
        fi
    fi
done

printf "\n![]($pathFile/temp/outputTemperature.png)" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md

printf "\n\n- **température min**: " >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf "%.1f" $minTemperature >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf "\n- **température max**: " >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf "%.1f" $maxTemperature >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md


printf "\n\n\n## Humidité" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
let moyenneHumidite=0
let minHumidite=100
let maxHumidite=0
for (( c=0; c<=$heure; c++ ))
do  
    if [ $(awk -F ":" '{if ($1=='$c'){print $0}}' 'temp/humidite'|awk "END{print NR}") -gt 0 ]
    then
        moyenneHumidite=$(awk -F ":" '{if ($1=='$c'){print $2}}' 'temp/humidite'| awk -F "_" 'BEGIN{sommeHumidite=0} {sommeHumidite+=$2} END{print (sommeHumidite/NR)}')
        testMin=$(awk '{print $1 < $2}' <<< "$moyenneHumidite $minHumidite" )
        testMax=$( awk '{print $1 < $2}' <<< "$maxHumidite $moyenneHumidite" )
        if [ "$testMin" -eq "1" ]
        then
            minHumidite=$moyenneHumidite
        fi
        if [ "$testMax" -eq "1" ]
        then
            maxHumidite=$moyenneHumidite
        fi
    fi
done

printf "\n![]($pathFile/temp/outputHumidite.png)" >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md

printf "\n\n- **humidité min**: " >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf "%.1f" $minHumidite >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf "\n- **humidité max**: " >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md
printf "%.1f" $maxHumidite >> $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md

name="$pathFile/rapport_meteo_lempereur_$date.pdf"
pandoc $pathFile/rapport_meteo_lempereur_$(date +"%d-%m-%Y").md -o $name
rm $pathFile/temp/*.png