#!/bin/bash
# ******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************
LOGFILE="/opt/plcnext/logs/NetworkSettings.log"
## Print  
ip addr
ip route

date >> ${LOGFILE}
ip addr >> ${LOGFILE}
ip route >> ${LOGFILE}

chown admin:plcnext ${LOGFILE}
