#!/bin/bash
# ******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************

FLAG=LAN
echo "Check Kernel Flags for:{FLAG}"
cat /proc/config.gz | gunzip | grep $FLAG
