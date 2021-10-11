#!/bin/bash
LargeFileLog="/opt/plcnext/logs/largeFile.log"

if [[ $1 == "help" ]]; then
echo "Usage: SearchLargeFiles.sh startDirectory DisplayXFiles"
echo "Example SearchLargeFiles.sh /var/log/ 20"
exit 255
fi

if [[ $1 == "" ]]; then
	STARTDIRECTORY="/var/volatile"
else
	STARTDIRECTORY=$1
fi

if [[ $2 == "" ]]; then
	LISTXXFILES=20 
else
	LISTXXFILES=$2
fi

echo "Search Dir:${STARTDIRECTORY} for large files/directories list X=${LISTXXFILES} largest Files in Byte"

if ! [ $(echo $STARTDIRECTORY | grep "/opt/") ] && [ $(whoami) != "root" ] ; then
	echo "please switch to root user to search all folders";
else
	du -a ${STARTDIRECTORY} | sort -n -r | head -n $LISTXXFILES >> /opt/plcnext/logs/largeFile.log
fi
