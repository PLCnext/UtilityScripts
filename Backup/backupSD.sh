#!/bin/bash
# ******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************
CURRENT=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
STORAGE_MODE=""
STORE_DEVICEDATA=false
STORE_LICENCE=false
STORE_CONTAINER=false
BACKUP_NAME="Backup"
DATE=$(date -I)

while getopts C:M:D:N:L:I:S:T: opt; 
do
        case "${opt}" in
        C) SETTINGS_PATH="$OPTARG";;
        M) SET_STORAGE_MODE="$OPTARG";;
        D) SET_STORE_DEVICEDATA="$OPTARG";;
        L) SET_STORE_LICENCE="$OPTARG";;
        I) SET_STORE_CONTAINER="$OPTARG";;
        N) BACKUP_NAME="$OPTARG";;
        S) SourceLocation="$OPTARG";;
        T) TargetLocation="$OPTARG";;
        *) echo '#Usage: \        
        #If only Storage mode is not set the Script will be started in interactive mode. \
        #Example for interactive backup: \
        # backupSD.sh -S /media/rfs/internalsd/ -T /media/rfs/externalsd \
        # \
        #Example for creating a backup of the internal storage \
        # \
        #"backupSD.sh -S /media/rfs/internalsd/ -T /media/rfs/externalsd/ -C backupSettings.sh -M PCWE -D true -L true -N "MyBackup" \
        # \
        # Options: \
        #-C Config \
        #       "SettingsFile.sh or /x/x/SettingsFile.sh Default: " \
        #-M Storage Mode: \
        #   "Upperdir / PCWE / SettingsFile" \        
        #-D Store DeviceData \
        #       "true/false" \
        #-L Store LicenseFiles \
        #       "true/false" \
        #-I Store Container \
        #       "true/false" \
        #-N Backup name \
        #       default "Backup" will result in Backup-$DATE.tar \
        #Mandatory: \
        #-S SourceLocation \
        #       /media/rfs/internalsd/ \
        #-T TargetLocation \
        #       /media/rfs/externalsd/'
        exit 1
        ;;
        esac
done



if [ "$(whoami)" != "root" ]; then
        echo "please use ROOT to create a backup";
        exit 255;
fi



## Set the root media to be backedup and the target location at which the backup will be stored.
if [[ $SourceLocation == "" && $TargetLocation == "" ]]; then
        echo "Usage: ./backupSD.sh -S SourceLocation -T TargetLocation";
        echo "Example: ./backupSD.sh -S /media/rfs/rw/upperdir/ -T /media/rfs/rw/";
        exit 255;
fi

## Set the settings and specific content locations for the backup from file.
echo SETTINGS_PATH="$SETTINGS_PATH";
if [ -f "$SETTINGS_PATH" ]; 
then
. $SETTINGS_PATH
elif [ -f "${SCRIPT_DIR}/$SETTINGS_PATH" ];
then
. ${SCRIPT_DIR}/$SETTINGS_PATH
else
. ${SCRIPT_DIR}/../Backup/backupSettings.sh
fi

##
## overwrite if set on CLI
##
if [ SET_STORAGE_MODE != "" ]; then
        STORAGE_MODE="$SET_STORAGE_MODE";
fi
if [ SET_STORE_DEVICEDATA != "" ]; then
        STORE_DEVICEDATA="$SET_STORE_DEVICEDATA";
fi
if [ SET_STORE_LICENCE != "" ]; then
        STORE_LICENCE="$SET_STORE_LICENCE";
fi
if [ SET_STORE_CONTAINER != "" ]; then
        STORE_CONTAINER="$SET_STORE_CONTAINER";
fi

# When STORAGE_MODE is set disable the interactive mode. Commandline > SettingsFile.
if [[ "$STORAGE_MODE" == "" ]]; then 
        INTERACTIVE=true
        echo "Interactive activated"
else
        INTERACTIVE=false
        echo "Interactive deactivated"
fi
###
### Start interactive settings
###
if [[ $INTERACTIVE == true ]]; 
then       
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
                                STORAGE_MODE="Upperdir"
                                echo "STORAGE_MODE = $STORAGE_MODE"            
                        ;;
                        
                        "PCWE Project only")
                                STORAGE_MODE="PCWE"
                                echo "STORAGE_MODE = $STORAGE_MODE"         
                        ;;
                        
                        "Directories specified by backupSettings.sh")
                                echo "check 'backupSettings.sh' to check or change settings"
                                (set -o posix ; set) | grep STORAGE_MODE | grep true
                                STORAGE_MODE="Changes"
                                echo "STORAGE_MODE = $STORAGE_MODE"            
                        ;;

                        # "Everything")
                        #         STORAGE_MODE="Everything"
                        #         echo "STORAGE_MODE = $STORAGE_MODE"         
                        # ;;

                        "Continue")
                                if [ "$STORAGE_MODE" == "" ]; then
                                        echo "STORAGE_MODE = $STORAGE_MODE empty Exit Script"   
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
        echo "SourceLocation: '$SourceLocation' The directory you want to backup."
        echo "TargetLocation: '$TargetLocation' the location you want to store your backup at."
        echo "Storage Mode: '$STORAGE_MODE' is activated."

        echo ":"
        read -r -p "Are you sure? [yes/No] all settings are correct
        " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then 
                exit 1;
        fi
fi

##
## Verify available diskspace
##
case $STORAGE_MODE in
        "Upperdir") 
                var=( $(du -s ${SourceLocation}/upperdir) )
                SpaceRequired=${var[0]} 
        ;;
        "Changes") 
                var=( $(du -s ${SourceLocation}/upperdir/opt/plcnext) )
                SpaceRequired=${var[0]} 
        ;; 
        "PCWE") 
                var=( $(du -s ${SourceLocation}/upperdir/opt/plcnext/projects/PCWE) )
                SpaceRequired=${var[0]} 
        ;;  
        *) SpaceRequired=0 
        ;;               

esac
##
## Diagnostics to help verify that the backuppath matches the active partition.
##
df -ha | grep rfs
${SCRIPT_DIR}/../Diagnostic/checkActivePartition.sh
if [[ $STORE_CONTAINER  == true ]]; 
then
        echo Add Container Size
        var=0
        SpaceRequired=$(($SpaceRequired + ${var[0]}))
fi

if [[ $STORE_DEVICEDATA == true ]]; 
then
        var=( $(du -s /etc/device_data))
        SpaceRequired=$(($SpaceRequired + ${var[0]}))
fi

if [[ $STORE_LICENCE == true ]]; 
then
        var=( $(du -s ${SourceLocation}/licence) )
        SpaceRequired=$(($SpaceRequired + ${var[0]}))
fi

var=( $(df --output=avail ${TargetLocation}) )
SpaceAvailable=${var[1]}

if [[ $SpaceRequired  -gt $SpaceAvailable ]]; 
then
        echo "WARNING you might not have enough space for this Backup!"
        echo "$SpaceRequired  -gt $SpaceAvailable"
else
        echo SpaceRequired: $SpaceRequired 
        echo SpaceAvailable: $SpaceAvailable
fi

###
### Start creating Backup
###
date > ${TargetLocation}/DATEFILE;
tar -cvpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${TargetLocation} DATEFILE

echo "STORAGE_MODE = $STORAGE_MODE" 
case "$STORAGE_MODE" in
        "Upperdir")
                echo "Storing Upperdir"                                                      
                tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} upperdir && echo "Done"  
        ;;

        "Changes")
                echo -e "Store specified folders only:"
                (set -o posix ; set) | grep "STORE" | grep "true"
                if [ $INTERACTIVE = true ]; 
                then       
                        read -r -p "Proceed creating backup [y/N]  :  " response
                        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]] 
                        then     
                                echo "Continue:"
                        else
                                exit 1;
                        fi
                fi
                ## Add Folders to Tar.
                if $STORE_UNIX_PASSWORD_CHANGES; 
                then
                        echo "Storing UNIX_PASSWORD_CHANGES"
                        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${UNIX_PASSWORD_Changes[@]} && echo "Done"
                fi
                if $STORE_NETWORK; 
                then
                        echo "Storing Network Settings"
                        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${NETWORK} && echo "Done"
                fi

                if $STORE_SSH_KEYs; 
                then
                        echo "Storing SSH Keys"
                        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${SSH_KEYs} && echo "Done"
                fi

                if $STORE_PLCnext_PROJECTS; 
                then
                        echo "Storing PROJECTS"
                        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${PROJECTS} && echo "Done"
                fi

                if $STORE_PLCnext_SYSTEM_UM; 
                then
                        echo "Storing SYSTEM UM Settings"
                        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${PLCnext_UM}&& echo "Done"
                fi

                if $STORE_PLCnext_SYSTEM_SCM; 
                then
                        echo "Storing SYSTEM SCM Settings"
                        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${PLCnext_SCM} && echo "Done"
                fi

                if $STORE_PLCNext_SERVICES; 
                then
                        echo  "Storing SERVICE Settings"
                        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${SERVICES} && echo "Done"
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

                if $STORE_PLCnext_SECURITY; 
                then
                        echo "Storing PLCnext_SECURITY directory"
                        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${PLCnext_SECURITY} && echo "Done"
                fi

                if $STORE_INSTALLED_APPS; 
                then
                        echo "Storing INSTALLED_APPS"
                        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${INSTALLED_APPS} && echo "Done"
                fi

                if $STORE_ALL_CONFIG; 
                then       
                        echo "Storing CONFIG directory"
                        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${CONFIG} && echo "Done"
                fi
                
                if $STORE_ALL_DATA; 
                then
                        echo "Storing DATA directory"
                        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${DATA} && echo "Done"
                fi  
        ;;

        "PCWE")         
                echo "Storing PCWE directory"       
                tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${PROJECTS} && echo "Done"
        ;;
esac


if [ $STORE_DEVICEDATA = true ]; 
then
        echo "WATCH OUT! 
        Stored DeviceData are bound to the Hardware of the PLC. Do not use this backup for another PLC!"
        echo "Storing DEVICEDATA"
        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C / ${DEVICEDATA} && echo "Done"
fi

if [[ $STORE_LICENCE == true ]]; 
then                
        echo "WATCH OUT! 
        Stored Licenses are bound to the Hardware ID. Do not use this backup for another PLC / SD"

        echo "WATCH OUT! 
        SD License is bound to this SD card. Do not use backup for another SD."
        if [[ $INTERACTIVE == true ]]; 
        then       
                read -r -p "Realy add License? [y/N]
                " response
                if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
                then
                        echo "Storing licence has been skipped"
                else 
                exit 1
                fi
        fi
        echo "Adding Licence, remember to unzip with caution!"
        echo "Restoring this backup might void an SD-Cards License if overwritten." 
        tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} ${INSTALLED_LICENSE_FILES} && echo "Done"
fi

if [[ $STORE_CONTAINER == true ]];
then
        echo "Storing Containers"
        ## Get a list of all containers
        CONTAINERS=($($CONTAINER_ENGINE container ls -aq))
        mkdir ${SourceLocation}Containers
        # Export Containers and add them to the backup.tar
        for CONTAINER in "${CONTAINERS[@]}"
        do
                echo "Storing Container:$CONTAINER"
                echo "This just saves the current state of the Container as an Image!"
                echo "You still need to Setup the Container again when restoring this backup"
                echo "$CONTAINER_ENGINE run -v XX -p xxx ... "
                ## Need to stop continers?                        
                $CONTAINER_ENGINE export $CONTAINER --output "${SourceLocation}/Containers/$CONTAINER.tar"
                tar -rpf ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar -C ${SourceLocation} "Containers/$CONTAINER.tar"
                rm "${SourceLocation}/Containers/$CONTAINER.tar"
        done && echo "Done"     
fi

if [ -f "${TargetLocation}/${BACKUP_NAME}-${DATE}.tar" ]; 
then
        chown admin:plcnext ${TargetLocation}/${BACKUP_NAME}-*.tar
        echo "Contents of Backup:"
        tar -tvf "${TargetLocation}/${BACKUP_NAME}-${DATE}.tar" | grep "/$"     
else
        echo "No backup created please fix your input data."
        exit 1
fi