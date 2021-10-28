#!/bin/bash
# ******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************

##Enable MemoryLogging
MEMORYLOG="/opt/plcnext/logs/memoryLog.log"

##
date >> $MEMORYLOG
ps --sort -rss -eo pid,pmem,rss,vsz,comm | head -16 >> $MEMORYLOG
df -ha | grep -E 't[[:alpha:]]{2}fs' >> $MEMORYLOG