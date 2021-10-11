#!/bin/bash
CURRENT=$(pwd)
DATAPATH="$1"
StoreBackupAt="$2"

if [[ $DATAPATH == "" && $StoreBackupAt == "" ]]; then
        echo "Usage: ./backupSD.sh DATAPATH StoreBackupAt";
        echo "Example: ./backupSD.sh /media/rfs/rw/ /media/rfs/rw/";
        exit 255;
fi
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

STORE_LICENCE=false
STORE_DEVICEDATA=false

STORE_UNIX_PASSWORD_CHANGES=true
STORE_PLCnextStuff=true
STORE_PLCnext_UM=true
STORE_NETWORK=true
STORE_SSH_KEYs=true
STORE_PROJECTS=true
STORE_INSTALLED_APPS=true
STORE_CONFIG=true
STORE_CERTS=true
STORE_DATA=true

UNIX_PASSWORD_Changes=( "upperdir/etc/shadow" "upperdir/etc/gshadow" "upperdir/etc/group" ) # created root user or admin unix pw was chaged.
PLCnextStuff="upperdir/etc/plcnext"                                 # All PCnext Stuff that has been modified. Database files for Firewall rules etc.
PLCnext_UM="upperdir/etc/plcnext/device/System/Um/Roles.settings"   # 
NETWORK="upperdir/etc/network"                                      # Interface file
SSH_KEYs="upperdir/etc/ssh"                                         # Unix Keys / not the Cert Storage
PROJECTS="upperdir/opt/plcnext/projects"                            # PCWE and other Project changes.
INSTALLED_APPS="upperdir/opt/plcnext/appshome"                      # 
CONFIG="upperdir/opt/plcnext/config"                                #
CERTS="upperdir/opt/plcnext/Security"                               #
DATA="upperdir/opt/plcnext/data"                                    #
INSTALLED_LICENSE_FILES="licence"                                   # SD card Licenses
DEVICEDATA="device_data"                                            # Production Data of PLC. 

df -ha | grep rfs
${SCRIPT_DIR}/../Diagnostic/checkActivePartition.sh

if [ "$(whoami)" != "root" ]; then
        echo "please use ROOT to create a backup";
        exit 255;
fi

echo 'Choose the kind of Backup you want to create.'
PS3="Select your choice: "
options=("Upperdir" "PCWE Project only" "Changes done via FW Services" "Continue" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "Upperdir")
                STORE="Upperdir"
                echo "STORE = $STORE"            
        ;;
        
        "PCWE Project only")
                STORE="PCWE"
                echo "STORE = $STORE"         
        ;;
        
        "Changes done via FW Services")
                STORE="Changes"
                echo "STORE = $STORE"            
        ;;
        
        "Continue")
                if [ "$STORE" == "" ]; then
                        echo "STORE = $STORE empty Exit Script"   
                exit 1
                fi
                break
        ;;
        
        "Exit")               
                exit 1        
                break
        ;;

        *) echo "invalid option $REPLY";;
    esac
done

echo 'Do you wish to add stored licenses and PLC device data to this backup?'
PS3="Select your choice: "
options=("Don't Store Licence" "Store Licence" "Don't Store DeviceData" "Store DeviceData" "Continue" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "Don't Store Licence")
                STORE_LICENCE=false
                echo "STORE_LICENCE = $STORE_LICENCE"            
        ;;
        "Store Licence")
                STORE_LICENCE=true
                echo "STORE_LICENCE = $STORE_LICENCE"            
        ;;
        "Don't Store DeviceData")
                STORE_DEVICEDATA=false
                echo "STORE_DEVICEDATA = $STORE_DEVICEDATA"            
        ;;
        "Store DeviceData")
                STORE_DEVICEDATA=true
                echo "STORE_DEVICEDATA = $STORE_DEVICEDATA"            
        ;;
        "Continue")
                if [ "$STORE_LICENCE" == "" ]; then
                        echo "STORE_LICENCE = $STORE_LICENCE empty. Exit Script."   
                exit 1
                fi
                if [ "$STORE_DEVICEDATA" == "" ]; then
                        echo "STORE_DEVICEDATA = $STORE_DEVICEDATA empty. Exit Script."   
                exit 1
                fi
                break
        ;;        
        "Exit")               
                exit 1        
                break
        ;;

        *) echo "invalid option $REPLY";;
    esac
done

echo "Please check if the paths are correct."
echo "DataPath: '$DATAPATH' The directory you want to backup."
echo "StoreBackupAt: '$StoreBackupAt' the location you want to store your backup at."
echo "STORE Mode: '$STORE' is activated."
echo "STORE_LICENCE: '$STORE_LICENCE' is activated."
echo "STORE_DEVICEDATA: '$STORE_DEVICEDATA' is activated."

read -r -p "Are you sure? [y/N] all settings are correct
" response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
        DATE=$(date -I)
        date > ${StoreBackupAt}/DATEFILE;
        tar -cvpf ${StoreBackupAt}/backup-${DATE}.tar -C ${StoreBackupAt} DATEFILE
        
        echo "STORE = $STORE" 
        case "$STORE" in
        "Upperdir")                                                      
                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} upperdir;  
        ;;
        "Changes")
                echo -e "Store specific folders only:"
                echo "STORE_UNIX_PASSWORD_CHANGES: $STORE_UNIX_PASSWORD_CHANGES
        | UNIX_PASSWORD_Changes: ${UNIX_PASSWORD_Changes[@]} "
                echo "STORE_NETWORK: $STORE_NETWORK
        | NETWORK: $NETWORK "
                echo "STORE_SSH_KEYs: $STORE_SSH_KEYs
        | SSH_KEYs: $SSH_KEYs "
                echo "STORE_PROJECTS: $STORE_PROJECTS
        | PROJECTS: $PROJECTS "
                echo "STORE_INSTALLED_APPS: $STORE_INSTALLED_APPS
        | INSTALLED_APPS: $INSTALLED_APPS "
                echo "STORE_CONFIG: $STORE_CONFIG
        | CONFIG: $CONFIG "
                echo "STORE_CERTS: $STORE_CERTS
        | CERTS: $CERTS "
                echo "STORE_DATA: $STORE_DATA
        | DATA: $DATA "               
                
                read -r -p "Proceed creating backup [y/N]  :  " response
                if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
                then     
                        ## Add Folders to Tar.
                        if $STORE_UNIX_PASSWORD_CHANGES; then
                                echo "STORED UNIX_PASSWORD_CHANGES"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${UNIX_PASSWORD_Changes[@]}
                        fi
                        if $STORE_NETWORK; then
                                echo "STORED NETWORK"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${NETWORK} 
                        fi
                        if $STORE_SSH_KEYs; then
                                echo "STORED SSH_KEYs"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${SSH_KEYs} 
                        fi
                        if $STORE_PROJECTS; then
                                echo "STORED PROJECTS"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${PROJECTS} 
                        fi
                        if $STORE_INSTALLED_APPS; then
                                echo "STORED INSTALLED_APPS"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${INSTALLED_APPS}
                        fi
                        if $STORE_CONFIG; then       
                                echo "STORED CONFIG"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${CONFIG}
                        fi
                        if $STORE_CERTS; then
                                echo "STORED CERTS"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${CERTS}
                        fi
                        if $STORE_DATA; then
                                echo "STORED DATA"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${DATA}
                        fi
                fi
        ;;

        "PCWE")         
                echo "STORED PCWE"       
                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${PROJECTS}
        ;;
        esac
fi

if $STORE_DEVICEDATA; then
        echo "WATCH OUT! 
        Stored DeviceData are bound to the Hardware of the PLC do not use this backup for another PLC!"
        echo "STORED DEVICEDATA"
        tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C "/etc" ${DEVICEDATA}
fi

if $STORE_LICENCE; then                
        echo "WATCH OUT! 
        Stored Licenses are bound to the Hardware ID do not use this backup for another PLC / SD"

        echo "WATCH OUT! 
        SD License is bound to this SD card do not use backup for another SD."

        read -r -p "Realy add License? [y/N]
        " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
                echo "Adding Licence, remember to unzip with caution!"
                echo "Restoring this backup might void an SD-Cards License if overwritten." 
                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${INSTALLED_LICENSE_FILES}
        else
                echo "Storing licence has been skipped"
        fi
fi

if [ -f "${StoreBackupAt}/backup-${DATE}.tar" ]; then
        chown admin:plcnext ${StoreBackupAt}/backup-*.tar
        echo "Contents of Backup:"
        tar --exclude "*/*"  -tvf "${StoreBackupAt}/backup-${DATE}.tar"

        echo "How to restore:
        ./restoreBackup.sh /media/rfs/rw/ /media/rfs/rw/backup-2021-09-10.tar
        "
else
	echo "No backup created please fix your input data."
        exit 1
fi