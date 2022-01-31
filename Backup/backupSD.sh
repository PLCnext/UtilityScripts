#!/bin/bash
# ******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************
CURRENT=$(pwd)
DATAPATH="$1"
StoreBackupAt="$2"

if [[ $DATAPATH == "" && $StoreBackupAt == "" ]]; then
        echo "Usage: ./backupSD.sh DATAPATH StoreBackupAt";
        echo "Example: ./backupSD.sh /media/rfs/rw/ /media/rfs/rw/";
        exit 255;
fi
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

## Set the directories for the backup
. ${SCRIPT_DIR}/../Backup/backupSettings.sh

df -ha | grep rfs
${SCRIPT_DIR}/../Diagnostic/checkActivePartition.sh

if [ "$(whoami)" != "root" ]; then
        echo "please use ROOT to create a backup";
        exit 255;
fi

echo 'Choose the kind of Backup you want to create.'
PS3="Select your choice: "
options=("Upperdir" \
"PCWE Project only" \
"Directories specified by backupSettings.sh" \
"Containers" \
"Continue" \
"Exit")
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
        
        "Directories specified by backupSettings.sh")
                echo "check 'backupSettings.sh' to check or change settings"
                (set -o posix ; set) | grep STORE | grep true
                STORE="Changes"
                echo "STORE = $STORE"            
        ;;

        # "Everything")
        #         STORE="Everything"
        #         echo "STORE = $STORE"         
        # ;;
        
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
options=("Don't Store Licence" 
"Store Licence" 
"Don't Store DeviceData" 
"Store DeviceData" 
"Don't Store Containers"
"Store Containers"
"Continue" 
"Exit" 
)
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
        "Store Containers")
                STORE_CONTAINER=true
                echo "STORE = $STORE"         
         ;;
        "Dont Store Containers")
                STORE_CONTAINER=false
                echo "STORE = $STORE"         
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

                if [ "$STORE_CONTAINER" == "" ]; then
                        echo "STORE_DEVICEDATA = $STORE_CONTAINER empty. Exit Script."   
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
echo "Storage Mode: '$STORE' is activated."


echo ":"
read -r -p "Are you sure? [y/N] all settings are correct
" response
###
### Storage Function
###
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
        DATE=$(date -I)
        date > ${StoreBackupAt}/DATEFILE;
        tar -cvpf ${StoreBackupAt}/backup-${DATE}.tar -C ${StoreBackupAt} DATEFILE
        
        echo "STORE = $STORE" 
        case "$STORE" in
        "Upperdir")
                echo "Storing Upperdir"                                                      
                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} upperdir && echo "Done"  
        ;;
        
        "Changes")
                echo -e "Store specified folders only:"
                (set -o posix ; set) | grep "STORE" | grep "true"           
                read -r -p "Proceed creating backup [y/N]  :  " response
                if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
                then     
                        ## Add Folders to Tar.
                        if $STORE_UNIX_PASSWORD_CHANGES; then
                                echo "Storing UNIX_PASSWORD_CHANGES"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${UNIX_PASSWORD_Changes[@]} && echo "Done"
                        fi
                        if $STORE_NETWORK; then
                                echo "Storing Network Settings"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${NETWORK} && echo "Done"
                        fi

                        if $STORE_SSH_KEYs; then
                                echo "Storing SSH Keys"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${SSH_KEYs} && echo "Done"
                        fi

                        if $STORE_PLCnext_PROJECTS; then
                                echo "Storing PROJECTS"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${PROJECTS} && echo "Done"
                        fi

                        if $STORE_PLCnext_SYSTEM_UM; then
                                echo "Storing SYSTEM UM Settings"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${PLCnext_UM}&& echo "Done"
                        fi

                        if $STORE_PLCnext_SYSTEM_SCM; then
                                echo "Storing SYSTEM SCM Settings"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${PLCnext_SCM} && echo "Done"
                        fi

                        if $STORE_PLCNext_SERVICES; then
                                echo  "Storing SERVICE Settings"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${SERVICES} && echo "Done"
                                ### If required add keys for specific services
                                #STORE_PLCNext_SERVICES_Ehmi
                                #STORE_PLCNext_SERVICES_Grpc                                
                                #STORE_PLCNext_SERVICES_LinuxSyslog
                                #STORE_PLCNext_SERVICES_OpcUA
                                #STORE_PLCNext_SERVICES_PLCnextStore
                                #STORE_PLCNext_SERVICES_PortAuthentication
                                #STORE_PLCNext_SERVICES_Spm
                                #STORE_PLCNext_SERVICES_SpnsProxy
                                #STORE_PLCNext_SERVICES_Syslog
                                #STORE_PLCNext_SERVICES_Wcm
                        fi
                        if $STORE_PLCnext_SECURITY; then
                                echo "Storing PLCnext_SECURITY directory"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${PLCnext_SECURITY} && echo "Done"
                        fi
                        if $STORE_INSTALLED_APPS; then
                                echo "Storing INSTALLED_APPS"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${INSTALLED_APPS} && echo "Done"
                        fi
                        if $STORE_ALL_CONFIG; then       
                                echo "Storing CONFIG directory"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${CONFIG} && echo "Done"
                        fi

                        if $STORE_ALL_DATA; then
                                echo "Storing DATA directory"
                                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${DATA} && echo "Done"
                        fi

                       
                fi
        ;;

        "PCWE")         
                echo "Storing PCWE directory"       
                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${PROJECTS} && echo "Done"
        ;;
        esac
fi

if $STORE_DEVICEDATA; then
        echo "WATCH OUT! 
        Stored DeviceData are bound to the Hardware of the PLC do not use this backup for another PLC!"
        echo "Storing DEVICEDATA"
        tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C "/etc" ${DEVICEDATA} && echo "Done"
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
                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} ${INSTALLED_LICENSE_FILES} && echo "Done"
        else
                echo "Storing licence has been skipped"
        fi
fi

if $STORE_CONTAINER; then             
        echo "Storing Containers"
        ## Get a list of all containers
        CONTAINERS=($(podman container ls -aq))
        mkdir ${DATAPATH}Containers
        # Export Containers and add them to the backup.tar
        for CONTAINER in "${CONTAINERS[@]}"
        do
                echo "Storing Container:$CONTAINER"
                echo "This just saves the current state of the Container as an Image!"
                echo "You still need to Setup the Container again when restoring this backup"
                echo "podman run -v XX -p xxx ... "
                ## Need to stop continers?                        
                $CONTAINER_ENGINE export $CONTAINER --output "${DATAPATH}/Containers/$CONTAINER.tar"
                tar -rpf ${StoreBackupAt}/backup-${DATE}.tar -C ${DATAPATH} "Containers/$CONTAINER.tar"
                rm "${DATAPATH}/Containers/$CONTAINER.tar"
        done && echo "Done"                
        ;;
fi

if [ -f "${StoreBackupAt}/backup-${DATE}.tar" ]; then
        chown admin:plcnext ${StoreBackupAt}/backup-*.tar
        echo "Contents of Backup:"
        tar -tvf "${StoreBackupAt}/backup-${DATE}.tar" | grep "/$"

        echo "How to restore:
        ./restoreBackup.sh /media/rfs/rw/ /media/rfs/rw/backup-${DATE}.tar
        "
else
	echo "No backup created please fix your input data."
        exit 1
fi