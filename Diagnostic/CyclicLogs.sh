#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

#s
SLEEP=100

##Enable MemoryLogging
MEMORYLOGGING=true

OPENSOCKETS=true

NETWORKSETTINGS=true

LARGEFILELOG=true

while true; do
	if $MEMORYLOGGING; then
		${SCRIPT_DIR}/MemoryLog.sh 
	fi

	if $OPENSOCKETS; then
		${SCRIPT_DIR}/CheckOpenSockets.sh 
	fi

	if $NETWORKSETTINGS; then
		${SCRIPT_DIR}/CheckNetworkSettings.sh
	fi
	
	if $LARGEFILELOG; then
		${SCRIPT_DIR}/SearchLargeFiles.sh "/var/volatile/" "20"		
	fi
sleep $SLEEP
done
