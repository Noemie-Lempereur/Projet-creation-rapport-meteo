#!/bin/bash

pathFile=$HOME

if [ ! -d $pathFile/temp ]
then
    mkdir $pathFile/temp
fi

wget "https://api.openweathermap.org/data/2.5/weather?lat=47.218371&lon=-1.553621&appid=ee4bbad0fcec46876c73fa6ad4faec06" --output-document=weather.json

date=$(date +"%d-%m-%Y")

temperature=$(awk -F\" '{print $31}' $pathFile/weather.json | sed 's/://g' | sed 's/,//g' | sed 's/}//g' | awk '{print $0-273.15}')
humidite=$(awk -F\" '{print $41}' $pathFile/weather.json | sed 's/://g' | sed 's/,//g' | sed 's/}//g')
temps=$(awk -F\" '{print $14}' $pathFile/weather.json | sed 's/://g' | sed 's/,//g' | sed 's/}//g')
icon=$(awk -F\" '{print $22}' $pathFile/weather.json | sed 's/://g' | sed 's/,//g' | sed 's/}//g')

heure=$(date +"%k" | sed "s/ //g")
minute=$(date +"%M" | sed "s/ //g")
touch "$pathFile/temp/temperature"
echo $heure":"$minute"_"$temperature>>$pathFile/temp/temperature

touch "$pathFile/temp/humidite"
echo $heure":"$minute"_"$humidite>>$pathFile/temp/humidite

touch "$pathFile/temp/ciel"
if [ $minute -ge 54 ]
then
    echo $heure"_"$temps"_"$icon>>$pathFile/temp/ciel
fi

    