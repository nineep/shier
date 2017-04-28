#!/bin/bash
#archive designated files and directories

DATE=`date +%y%m%d`

#set archive file name
FILE=archive$DATE.tar.gz

#set config & destination file
CONFIG_FILE=/home/user/archive/file_to_backup
DESTINATION=/home/user/archive/$FILE

#check backup config file exists
if [ -f $CONFIG_FILE ]
then
	echo ""
else
	echo "$CONFIG_FILE does not exist. backup not completed due to missing configuration file"
	exit
fi

#build the names of all the files to backup
FILE_NO=1
exec < $CONFIG_FILE
read FILE_NAME
while [ $? -eq 0 ]
do
	if [ -f $FILE_NAME -o -d $FILE_NAME ]
	then
		#if file exists,add its name to the list
		FILE_LIST="$FILE_LIST $FILE_NAME"
	else
		echo "$FILE_NAME does not exist. it is listed on line $FILE_NO of teh config file."
		echo "continuing to build archive list..."
	fi

	FILE_NO=$[$FILE_NO + 1]
	read FILE_NAME
done

#backup the files and compress archive
tar -czf $DESTINATIOPN $FILE_LIST 2> /dev/null
