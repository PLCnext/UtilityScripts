#!/bin/bash
# ******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************
NEWTIMEZONE="Europe/Berlin"

## Print current Timezone:
ls -la /etc/localtime 
date

##/etc/localtime -> /usr/share/zoneinfo/Europe/Berlin
ln -sf /usr/share/zoneinfo/${NEWTIMEZONE} /etc/localtime

ls -la /etc/localtime 
date