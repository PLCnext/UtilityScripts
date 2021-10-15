#!/bin/bash
# ******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************
PORT="$1"
TYPE="$2" 

LOGFILE="/opt/plcnext/logs/opensockets.logs"

echo "######Listening Ports" 
netstat -lan >> $LOGFILE 
date >> $LOGFILE 
echo "Logging done" >> $LOGFILE 

if [ -f ${LOGFILE} ]; then 
echo "Logfile:${LOGFILE} created." 
tail -n 2 ${LOGFILE} 
fi

### Check what application is using a specific Port
PORT="161"
TYPE="udp" 
if [ "$(whoami)" = "root" ]; then
        echo "######check specific Port:${PORT} Type:${TYPE}" >> ${LOGFILE} && tail -n 1 ${LOGFILE}
	netstat -lan | grep ${PORT}
	PID=$(fuser ${PORT}/${TYPE})
	ps -ef | grep ${PID} | grep -v "grep" >> ${LOGFILE} && tail -n 1 ${LOGFILE};
	echo "^^^^^^This Application is using the specified port"
else
    echo "To check which application is using a specific port: run as root"
fi

chown admin:plcnext ${LOGFILE}
