#!/bin/bash
# ******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************
STORAGE_MODE="PCWE"
###
### Located on the SD
###
STORE_LICENCE=false     # SD card Licenses
INSTALLED_LICENSE_FILES="licence"                                

###
### Located on InternalStorage
###
STORE_DEVICEDATA=false  # Production Data of PLC. 
DEVICEDATA="etc/device_data"                                       

###
### Located on Upperdir
###
STORE_UNIX_PASSWORD_CHANGES=true    # Created root user, added groups etc.
UNIX_PASSWORD_Changes=( "/etc/shadow" "/etc/gshadow" "/etc/group" ) # created root user or admin unix pw was chaged.

STORE_PLCnext_ETC=false    # All modifications done to the /etc/plcnext directory
PLCnext_ETC="upperdir/etc/plcnext"                                

#STORE_PLCnext_SYSTEM
STORE_PLCnext_SYSTEM_UM=true    # Added roles and Permissions as well as Ldap Config
PLCnext_UM="upperdir/opt/plcnext/config/System/Um/"               

STORE_PLCnext_SYSTEM_SCM=true  # Service Manager changes to enable/disable System Features
PLCnext_SCM="upperdir/opt/plcnext/config/System/Scm/"   

STORE_PLCnext_SECURITY=true     # Certificates IdentityStores and Truststores
PLCnext_SECURITY="upperdir/opt/plcnext/Security"                          

STORE_PLCnext_PROJECTS=true     # PCWE and other Project changes.
PROJECTS="upperdir/opt/plcnext/projects" 

STORE_PLCNext_SERVICES=true # Service Specific Settings
SERVICES="upperdir/opt/plcnext/config/Services"

STORE_NETWORK=true # Store your custom IP Configuration
NETWORK="upperdir/etc/network"

STORE_SSH_KEYs=true # Unix SSH Keys
SSH_KEYs="upperdir/etc/ssh"                              

STORE_INSTALLED_APPS=false # 
INSTALLED_APPS="upperdir/opt/plcnext/appshome" 

STORE_ALL_CONFIG=false # Whole config directory
CONFIG="upperdir/opt/plcnext/config"

STORE_ALL_DATA=false # this directory holds mostly session dependend data like PIDs, FW update Status etc.
DATA="upperdir/opt/plcnext/data"

STORE_CONTAINER=false
CONTAINER_ENGINE=podman