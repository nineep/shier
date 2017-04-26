#!/bin/bash

#find big disk space users in various directories

#parameters for script
CHECK_DIRECTORIES="/var/log /home"
DATE=$(date '+%m%d%y')

exec > disk_space_$DATE.log
echo "Top ten disk space usage for $CHECK_DIRECTORIES directories"
for DIR_CHECK in $CHECK_DIRECTORIES
do
	echo ""
	echo "The $DIR_CHECK directories:"
	#create a listing of top ten disk space users
	du -S $DIR_CHECK 2>/dev/null |
	sort -rn |
	sed '{11,$D; =}' |
	sed 'N; s/\n/ /' |
	awk '{printf $1 ":" "\t" $2 "\t" $3 "\n"}'
done                                       

