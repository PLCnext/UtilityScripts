#!/bin/bash
# ******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************
# PermitRootLogin yes
# OLD: #PermitRootLogin yes
# NEW: PermitRootLogin yes
echo OLD:
cat /etc/ssh/sshd_config |grep PermitRootLogin
sed -i.backup -E "s/#.*PermitRootLogin/PermitRootLogin yes#/g" /etc/ssh/sshd_config 
echo NEW:
cat /etc/ssh/sshd_config |grep PermitRootLogin
