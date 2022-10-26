#!/bin/bash


(crontab -l 2>/dev/null; echo "*/5 * * * * $HOME/weatherv3.sh")| crontab
(crontab -l 2>/dev/null; echo "57 23 * * * $HOME/generationRapportFinalv3.sh")| crontab
(crontab -l 2>/dev/null; echo "58 23 * * * rm $HOME/temp/*")| crontab
sudo service cron start