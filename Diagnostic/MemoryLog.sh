#!/bin/bash
##SleepTime in Seconds


##Enable MemoryLogging
MEMORYLOG="/opt/plcnext/logs/memoryLog.log"

##
date >> $MEMORYLOG
ps --sort -rss -eo pid,pmem,rss,vsz,comm | head -16 >> $MEMORYLOG
df -ha | grep -E 't[[:alpha:]]{2}fs' >> $MEMORYLOG