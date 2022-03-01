#!/bin/bash
# ******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************
STORAGE_MODE="PCWE" # 
###
### Located on the SD
###
STORE_SD_LICENCE=false     # SD card Licence
INSTALLED_LICENSE_FILES="licence"                                


STORE_PLCNEXTSTORE_LICENCE=false     # PLCnext Store Licence files
INSTALLED_LICENSE_FILES="NotImplemented"                                

###
### Located on internal storage
###
STORE_DEVICEDATA=false  # Production Data of PLC. 
DEVICEDATA="etc/device_data"                                       

###
### Located on Upperdir
###
### Needs Root privileges
STORE_UNIX_PASSWORD_CHANGES=false    # Created root user, added groups etc.
UNIX_PASSWORD_Changes=( "upperdir/etc/shadow" "upperdir/etc/gshadow" "upperdir/etc/group" ) # created root user or admin unix pw was chaged.

### Needs Root privileges
STORE_PLCnext_ETC=false    # All modifications done to the /etc/plcnext directory
PLCnext_ETC="upperdir/etc/plcnext"                                

#STORE_PLCnext_SYSTEM
STORE_PLCnext_SYSTEM_UM=true    # Added roles and Permissions as well as Ldap Config
PLCnext_UM="upperdir/opt/plcnext/config/System/Um/"               

STORE_PLCnext_SYSTEM_SCM=true  # Service Manager changes to enable/disable System Features
PLCnext_SCM="upperdir/opt/plcnext/config/System/Scm/"   

STORE_PLCnext_SYSTEM_WATCHDOG=true  # Service Manager changes to enable/disable System Features
PLCnext_WATCHDOG="upperdir/opt/plcnext/config/System/Watchdog/"   

STORE_PLCnext_SECURITY=true     # Certificates IdentityStores and Truststores
PLCnext_SECURITY="upperdir/opt/plcnext/Security"                          

STORE_PLCnext_PROJECTS=true     # PCWE and other Project changes.
PROJECTS="upperdir/opt/plcnext/projects" 

STORE_PLCNext_SERVICES=true # Service Specific Settings
SERVICES="upperdir/opt/plcnext/config/Services"

# STORE_PLCNext_SERVICES_Ehmi
# STORE_PLCNext_SERVICES_Grpc                                
# STORE_PLCNext_SERVICES_LinuxSyslog
# STORE_PLCNext_SERVICES_OpcUA
# STORE_PLCNext_SERVICES_PLCnextStore
# STORE_PLCNext_SERVICES_PortAuthentication
# STORE_PLCNext_SERVICES_Spm
# STORE_PLCNext_SERVICES_SpnsProxy
# STORE_PLCNext_SERVICES_Syslog
# STORE_PLCNext_SERVICES_Wcm # Certificates and additional nginx location config
# STORE_PLCnext_STORE_Licenses

STORE_NETWORK=true # Store your custom IP Configuration
NETWORK="upperdir/etc/network"

### Needs Root privileges
STORE_SSH_KEYs=false # Unix SSH Keys
SSH_KEYs="upperdir/etc/ssh"                              

STORE_INSTALLED_APPS=true # 
INSTALLED_APPS="upperdir/opt/plcnext/installed_apps" 
INSTALLED_APP_STATUS="upperdir/opt/plcnext/appshome" 

### Needs Root privileges (PnS NBHinfo, RPCState, etc..)
STORE_ALL_CONFIG=false # Whole config directory
CONFIG="upperdir/opt/plcnext/config"

STORE_ALL_DATA=false # this directory holds mostly session dependend data like PIDs, FW update Status etc.
DATA="upperdir/opt/plcnext/data"

### Needs Root privileges
STORE_CONTAINER=false
CONTAINER_ENGINE=podman