#!/bin/bash
LOGFILE="/opt/plcnext/logs/NetworkSettings.log"
## Print  
ip addr
ip route

date >> ${LOGFILE}
ip addr >> ${LOGFILE}
ip route >> ${LOGFILE}

chown admin:plcnext ${LOGFILE}
