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
STORE_SD_LICENCE=false
STORE_CONTAINER=false
BACKUP_NAME="Backup"
DATE=$(date -I)

while getopts C:M:D:N:L:I:S:T: opt; 
do
        case "${opt}" in
        C) SETTINGS_PATH="$OPTARG";;
        M) SET_STORAGE_MODE="$OPTARG";;
        D) SET_STORE_DEVICEDATA="$OPTARG";;
        L) SET_STORE_SD_LICENCE="$OPTARG";;
        I) SET_STORE_CONTAINER="$OPTARG";;
        N) BACKUP_NAME="$OPTARG";;
        S) SourceLocation="$OPTARG";;
        T) TargetLocation="$OPTARG";;
        *) echo '#Usage: \        
        #If only Storage mode is not set the Script will be started in interactive mode. \
        #Example for interactive backup: \
        # backupSD.sh -S /media/rfs/internalsd -T /media/rfs/externalsd \
        # \
        #Example for creating a backup of the internal storage \
        # \
        #"backupSD.sh -S /media/rfs/internalsd -T /media/rfs/externalsd -C backupSettings.sh -M PCWE -D false -L true -N "MyBackup" \
        # \
        # Options: \
        #-C Config \
        #       "SettingsFile.sh or /x/x/SettingsFile.sh \
        # Default: backupSettings.sh" \
        #-M Storage Mode: \
        #   "Upperdir / PCWE / SettingsFile / Manual" \    
        # Default: "" = Manual    
        #-D Store DeviceData \
        #       "true/false" \
        # Default: false
        #-L Store LicenseFiles \
        #       "true/false" \
        # Default: false
        #-I Store Container \
        #       "true/false" \
        # Default: false
        #-N Backup name \      
        # Default: "Backup"    will result in "Backup-$DATE.tar" \
        #Mandatory: \
        #-S SourceLocation \
        #       /media/rfs/internalsd \
        #-T TargetLocation \
        #       /media/rfs/externalsd'
        exit 1
        ;;
        esac
done

function Toggle(){
 if [ $1 = true ] ; then echo false; else echo true; fi
}

VerifyUser() {
        if [ "$(whoami)" != "root" ]; then
                echo "please use ROOT to create a backup with these options"
                echo "or disable the option to add these files to your backup"
                set | grep "STORE_"
                exit 255;
        fi
}


## Set the root media to be backedup and the target location at which the backup will be stored.
if [[ $SourceLocation == "" && $TargetLocation == "" ]]; then
        echo "Check Source and TargetLocation"
        echo "Usage: ./backupSD.sh -S SourceLocation -T TargetLocation";
        echo "Example: ./backupSD.sh -S /media/rfs/rw/upperdir/ -T /media/rfs/rw/";
        exit 255;
fi


## Set the settings and specific content locations for the backup from file.
echo "Initialize variables via SETTINGS_PATH"
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
echo "Overwrite variables entered via CLI"
if [ SET_STORAGE_MODE != "" ]; then
        STORAGE_MODE="$SET_STORAGE_MODE";
fi
if [ SET_STORE_DEVICEDATA != "" ]; then
        STORE_DEVICEDATA=$SET_STORE_DEVICEDATA;
fi
if [ SET_STORE_SD_LICENCE != "" ]; then
        STORE_SD_LICENCE=$SET_STORE_SD_LICENCE;
fi
if [ SET_STORE_CONTAINER != "" ]; then
        STORE_CONTAINER=$SET_STORE_CONTAINER;
fi

echo "Set Interactive mode"
# When STORAGE_MODE is set disable the interactive mode. Commandline > SettingsFile.
if [[ "$STORAGE_MODE" == "" || "$STORAGE_MODE" == "Manual" ]]; then 
        INTERACTIVE=true
        echo "Interactive activated"
else
        INTERACTIVE=false
        echo "Interactive deactivated"
fi
case $STORAGE_MODE in
        "Upperdir") :;;
        "PCWE") :;;
        "SettingsFile") :;;
        "Manual") 
        STORAGE_MODE="Manual"
        INTERACTIVE=true
        ;;
        "") 
        STORAGE_MODE="Manual"
        INTERACTIVE=true;;
        *) 
                echo "Mode: $STORAGE_MODE not supported"
                exit 1
        ;;
esac


echo "Interactive mode ${INTERACTIVE}"
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
        "Manual Selection" \
        "Continue" \
        "Exit")
        select opt in "${options[@]}"
        do
                case $opt in
                        "Upperdir")
                                STORAGE_MODE="Upperdir"
                                echo "STORAGE_MODE = $STORAGE_MODE"                                
                                echo "Needs Root privileges Currentuser:$(whoami)"     
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

                        "Manual Selection")
                                 STORAGE_MODE="Manual"
                                 INTERACTIVE=true
                                 echo "STORAGE_MODE = $STORAGE_MODE"         
                        ;;

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

                        *) echo "invalid option $REPLY"
                        ;;
                esac
        done

        if [ ${STORAGE_MODE} = "Manual" ]; 
        then
                echo 'Do you wish to add stored licenses and PLC device data to this backup?'
                PS3="Toggle your choice to overwrite settings loaded from config: "
                options=( 
                "Toggle store SD_Licence"
                "Toggle store PLCNEXTSTORE_Licence"           
                "Toggle store DeviceData"        
                "Toggle store Containers"
                "Toggle store UNIX_PASSWORD_CHANGES"   # Created root user, added groups etc.
                "Toggle store PLCnext_ETC"    # All modifications done to the /etc/plcnext directory        
                "Toggle store PLCnext_SYSTEM_UM"    # Added roles and Permissions as well as Ldap Config
                "Toggle store PLCnext_SYSTEM_SCM"  # Service Manager changes to enable/disable System Features
                "Toggle store PLCnext_SECURITY"   # Certificates IdentityStores and Truststores
                "Toggle store PLCnext_PROJECTS"   # PCWE and other Project changes.
                "Toggle store PLCNext_SERVICES" # Service Specific Settings
                "Toggle store NETWORK" # Store your custom IP Configuration
                "Toggle store SSH_KEYs" # Unix SSH Keys
                "Toggle store INSTALLED_APPS" # 
                "Toggle store ALL_CONFIG" # Whole config directory
                "Toggle store ALL_DATA" # this directory holds mostly session dependend data like PIDs, FW update Status etc.               
                "List all"
                "Continue" 
                "Exit" 
                )        
                select opt in "${options[@]}"
                do
                        case $opt in     
                                "Toggle store SD_Licence")
                                        echo "Saving SD HW specific productiondata."                                       
                                        STORE_SD_LICENCE=$(Toggle ${STORE_SD_LICENCE})
                                        echo "STORE_SD_LICENCE = $STORE_SD_LICENCE"            
                                ;;

                                "Toggle store PLCNEXTSTORE_Licence")
                                        echo "not implemented"
                                ;;

                                "Toggle store DeviceData")
                                        echo "Saving device specific productiondata."
                                        echo "Needs Root privileges current user: $(whoami)"                                            
                                        STORE_DEVICEDATA=$(Toggle ${STORE_DEVICEDATA})
                                        echo "STORE_DEVICEDATA = $STORE_DEVICEDATA"            
                                ;;

                                "Toggle store Containers")
                                        echo "Saving current state of $CONTAINER_ENGINE Containers"
                                        echo "Needs Root privileges Currentuser:$(whoami)"     
                                        STORE_CONTAINER=$(Toggle ${STORE_CONTAINER})
                                        echo "STORE_CONTAINER = ${STORE_CONTAINER}"   
                                ;;
                                "Toggle store UNIX_PASSWORD_CHANGES")
                                        echo   "Save Created root user, added groups etc."
                                        STORE_UNIX_PASSWORD_CHANGES=$(Toggle ${STORE_UNIX_PASSWORD_CHANGES})
                                        echo "STORE_UNIX_PASSWORD_CHANGES = ${STORE_UNIX_PASSWORD_CHANGES}"   
                                ;;
                                "Toggle store PLCnext_ETC")
                                        echo "Save all modifications done to the /etc/plcnext directory "
                                        echo "Needs ROOT privileges"
                                        STORE_PLCnext_ETC=$(Toggle $STORE_PLCnext_ETC)
                                        echo "STORE_PLCnext_ETC = $STORE_PLCnext_ETC"   
                                ;;

                                "Toggle store PLCnext_SYSTEM_UM")    
                                        echo "Save roles added via PLCnext UM, Permissions as well as Ldap Config"
                                        STORE_PLCnext_SYSTEM_UM=$(Toggle $STORE_PLCnext_SYSTEM_UM)
                                        echo "STORE_PLCnext_SYSTEM_UM = $STORE_PLCnext_SYSTEM_UM"   
                                ;;
                                "Toggle store PLCnext_SYSTEM_SCM")  
                                        echo "Service Manager changes to enable/disable System Features"
                                        STORE_PLCnext_SYSTEM_SCM=$(Toggle $STORE_PLCnext_SYSTEM_SCM)
                                        echo "STORE_PLCnext_SYSTEM_SCM = $STORE_PLCnext_SYSTEM_SCM" 
                                ;;

                                "Toggle store PLCnext_SECURITY")
                                        echo "Certificates IdentityStores and Truststores"
                                        STORE_PLCnext_SECURITY=$(Toggle $STORE_PLCnext_SECURITY)
                                        echo "STORE_PLCnext_SECURITY = $STORE_PLCnext_SECURITY"
                                ;;
                                "Toggle store PLCnext_PROJECTS")
                                        echo "PLCnext Engineer Projects and other deployed ACF Components located at $PROJECTS"
                                        STORE_PLCnext_PROJECTS=$(Toggle $STORE_PLCnext_PROJECTS)
                                        echo "STORE_PLCnext_PROJECTS = $STORE_PLCnext_PROJECTS"  
                                ;;
                                "Toggle store PLCNext_SERVICES")
                                        echo "PLCnext Service Specific Settings"
                                        STORE_PLCNext_SERVICES=$(Toggle $STORE_PLCNext_SERVICES)
                                        echo "STORE_PLCNext_SERVICES = $STORE_PLCNext_SERVICES"   
                                ;;
                                "Toggle store NETWORK")
                                        echo "Store your custom IP Configuration"
                                        STORE_NETWORK=$(Toggle $STORE_NETWORK)
                                        echo "STORE_NETWORK = $STORE_NETWORK"   
                                ;;
                                "Toggle store SSH_KEYs")
                                        echo "Unix SSH Keys"
                                        STORE_SSH_KEYs=$(Toggle $STORE_SSH_KEYs)
                                        echo "STORE_SSH_KEYs = $STORE_SSH_KEYs"
                                ;;   
                                "Toggle store INSTALLED_APPS")
                                        echo "Saveapps installed via PLCnext Store or WBM" 
                                        STORE_INSTALLED_APPS=$(Toggle $STORE_INSTALLED_APPS)
                                        echo "STORE_INSTALLED_APPS = $STORE_INSTALLED_APPS"   
                                ;;
                                "Toggle store ALL_CONFIG")
                                        echo "Whole PLCnext config directory located at $CONFIG"
                                        STORE_ALL_CONFIG=$(Toggle $STORE_ALL_CONFIG)
                                        echo "STORE_ALL_CONFIG = $STORE_ALL_CONFIG"
                                ;;
                                "Toggle store ALL_DATA")
                                        echo "this directory holds mostly session dependend data like PIDs, FW update Status etc"
                                        STORE_ALL_DATA=$(Toggle $STORE_ALL_DATA)
                                        echo "STORE_ALL_DATA = $STORE_ALL_DATA"
                                ;;
                                "List all")                                
                                set | grep STORE
                                ;;

                                "Continue")
                                        set | grep STORE
                                        read -r -p "Are you sure you wish to continue? [yes/No] all settings are correct
                                        " response
                                        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
                                        then 
                                                break;
                                        fi                                        
                                ;;        
                                "Exit")               
                                        exit 1        
                                        break
                                ;;

                                *) echo "invalid option $REPLY"
                                   echo "Press Enter to recieve valid options again"
                                ;;
                        esac
                done

                while true; do
                        echo "Please check if the paths are correct."
                        echo "SourceLocation: '$SourceLocation' The directory you want to backup."
                        echo "TargetLocation: '$TargetLocation' the location you want to store your backup at."
                        echo "Storage Mode: '$STORAGE_MODE' is activated."

                        echo ":"
                        read -r -p "Are you sure? [yes/No] all settings are correct
                        " response
                        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
                        then 
                                read -r -p "New SourceLocation\
                                " SourceLocation
                                read -r -p "New TargetLocation\
                                " SourceLocation
                        else
                                break
                        fi
                done
        fi
fi


echo "Disk diagnostics:"
##
## Diagnostics to help verify that the backuppath matches the active partition.
df -h | grep rfs
#${SCRIPT_DIR}/../Diagnostic/checkActivePartition.sh

##
## Verify available diskspace
##
echo "Verify available diskspace"
case $STORAGE_MODE in
        "Upperdir") 
                var=( $(du -s ${SourceLocation}/upperdir) )
                SpaceRequired=${var[0]} 
        ;;
        "SettingsFile") 
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

if [[ $STORE_CONTAINER  == true ]]; 
then
        echo "Calculation of Container size not implemented"
        echo "caution when multiple Containers depend on identical base layers" 
        echo "the resulting backup might be significantly larger then the space required on Disk"
        echo "Add Container Size"
        var=0
        SpaceRequired=$(($SpaceRequired + ${var[0]}))
        VerifyUser
fi

if [[ $STORE_DEVICEDATA == true ]]; 
then
        var=( $(du -s /etc/device_data) )
        SpaceRequired=$(($SpaceRequired + ${var[0]}))
        VerifyUser
fi
if [[ $STORE_SD_LICENCE == true ]]; 
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
### Prepare Backup
###
echo "Prepare Backup"
date > ${TargetLocation}/DATEFILE;
BACKUPFILE_LIST=( "${TargetLocation}/DATEFILE" )

## File Delimiter to newline this is important to support filenames with whitespace.
IFS=$'\n'

echo "STORAGE_MODE = $STORAGE_MODE" 
case "$STORAGE_MODE" in
        "Upperdir")
                echo "Storing Upperdir this usually contains all userdata (except Containers)"
                VerifyUser
                BACKUPFILE_LIST+=( $(find ${SourceLocation}/upperdir))                
                echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
        ;;

        "SettingsFile")
                echo -e "Store folders specified by Config file only:"
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
                
                if $STORE_UNIX_PASSWORD_CHANGES; 
                then                        
                        echo "Storing UNIX_PASSWORD_CHANGES"
                        VerifyUser
                        for Location in ${UNIX_PASSWORD_Changes[@]}; do
                                if [ -f ${SourceLocation}/${Location} ];  
                                then
                                BACKUPFILE_LIST+=( $(find ${SourceLocation}/${Location}) )
                                fi
                                echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                        done
                        
                fi
                if $STORE_NETWORK; 
                then
                        echo "Storing Network Settings"
                     
                        BACKUPFILE_LIST+=($(find ${SourceLocation}/${NETWORK}) )
                        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                fi

                if $STORE_PLCnext_ETC; 
                then
                        echo "Storing upperdir/etc/plcnext"
                        VerifyUser
                        BACKUPFILE_LIST+=($(find ${SourceLocation}/${PLCnext_ETC}) )                        
                        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                fi

                if $STORE_SSH_KEYs; 
                then
                        echo "Storing SSH Keys"
                        VerifyUser
                        BACKUPFILE_LIST+=($(find ${SourceLocation}/${SSH_KEYs}) )                        
                        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                fi

                if $STORE_PLCnext_PROJECTS; 
                then
                        echo "Storing PROJECTS"                       
                        BACKUPFILE_LIST+=( $(find ${SourceLocation}/${PROJECTS}) )
                        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                fi

                if $STORE_PLCnext_SYSTEM_UM; 
                then
                        echo "Storing SYSTEM UM / UserManager Settings"                       
                        BACKUPFILE_LIST+=( $(find ${SourceLocation}/${PLCnext_UM}) )
                        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                fi

                if $STORE_PLCnext_SYSTEM_SCM; 
                then
                        echo "Storing SYSTEM SCM Settings"
                    
                        if [ -d  ${SourceLocation}/${PLCnext_SCM} ] ;
                        then
                        BACKUPFILE_LIST+=( $(find ${SourceLocation}/${PLCnext_SCM}) )
                        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                        fi
                fi

                if $STORE_PLCNext_SERVICES; 
                then
                        echo  "Storing SERVICE Settings"                       
                        if [ -d  ${SourceLocation}/${SERVICES} ];
                        then                        
                        BACKUPFILE_LIST+=( $(find ${SourceLocation}/${SERVICES}) )
                        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                        fi
                        ### If required we could add keys for each specific services
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
                        if [ -d  ${SourceLocation}/${PLCnext_SECURITY} ];
                        then  
                        BACKUPFILE_LIST+=($(find ${SourceLocation}/${PLCnext_SECURITY}))
                        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                        fi
                fi

                if $STORE_INSTALLED_APPS; 
                then
                        echo "Storing INSTALLED_APPS"
                       
                        BACKUPFILE_LIST+=($(find ${SourceLocation}/${INSTALLED_APPS}) )
                        BACKUPFILE_LIST+=( $(find ${SourceLocation}/${INSTALLED_APP_STATUS}) )
                        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                fi


                if $STORE_ALL_CONFIG; 
                then       
                        echo "Storing PLCnext CONFIG directory"                      
                        BACKUPFILE_LIST+=( $(find ${SourceLocation}/${CONFIG}) )
                        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                fi
                
                if $STORE_ALL_DATA; 
                then
                        echo "Storing PLCnext DATA directory"                      
                        BACKUPFILE_LIST+=( $(find ${SourceLocation}/${DATA}) )
                        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                fi  
        ;;

        "PCWE")         
                echo "Storing PLCnext Engineer project directory"               
                BACKUPFILE_LIST+=( $(find ${SourceLocation}/${PROJECTS}) )
                echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
        ;;
esac


if [[ $STORE_DEVICEDATA == true ]]; 
then
        
        echo "WATCH OUT! 
        Stored DeviceData are bound to the Hardware of the PLC. Do not use this backup for another PLC!"
        echo "Storing DEVICEDATA"        
      
        BACKUPFILE_LIST=( "${BACKUPFILE_LIST[@]}" $(find  /${DEVICEDATA}) )
        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
fi

if [[ $STORE_SD_LICENCE == true ]]; 
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
    
        BACKUPFILE_LIST+=( $(find  ${SourceLocation}/${INSTALLED_LICENSE_FILES}) )
        echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
fi

if [[ $STORE_CONTAINER == true ]];
then
        echo "Storing Containers"
        ## Get a list of all containers
        CONTAINERS=($($CONTAINER_ENGINE container ls -aq))
        mkdir ${SourceLocation}/Containers
        # Export Containers and add them to the backup.tar
        for CONTAINER in "${CONTAINERS[@]}"
        do
                echo "Storing Container:$CONTAINER"
                echo "This just saves the current state of the Container as an Image!"
                echo "You still need to Setup the Container again when restoring this backup"
                echo "$CONTAINER_ENGINE run -v XX -p xxx ... "
                ## Need to stop continers?                        
                $CONTAINER_ENGINE export $CONTAINER --output "${SourceLocation}/Containers/$CONTAINER.tar"
          
                BACKUPFILE_LIST+=( $(find ${SourceLocation}/Containers/$CONTAINER.tar) )
                echo "Number of Entries:${#BACKUPFILE_LIST[@]}"
                rm "${SourceLocation}/Containers/$CONTAINER.tar"
        done && echo "Done"     
fi

echo "###"
echo "### Prepare Backup"
echo "###"
BACKUPFILE_LIST+=( "${TargetLocation}/ListOfFiles-${DATE}.txt" )
BACKUPFILE_LIST+=( "${TargetLocation}/ListWithChecksum-${DATE}.txt" )

echo "Number of Folders/Files:${#BACKUPFILE_LIST[@]}"
printf "%s\n" "${BACKUPFILE_LIST[@]}"
printf "%s\n" "${BACKUPFILE_LIST[@]}" > ${TargetLocation}/ListOfFiles-${DATE}.txt
declare -a ListWithChecksum

echo "###"
echo "### Create Checksum"
echo "###"
for file in "${BACKUPFILE_LIST[@]}"; do
        if [[ -d ${file} ]];
        then
                #echo "${file} : No hash its a directory"
        :               
        elif [[ -f ${file} ]]; 
        then
                #echo "${file} is a file"
                ListWithChecksum+=( "$(openssl sha256 ${file})" )
        else
                echo "${file} is not valid"      
        fi
done
printf "%s\n" "${ListWithChecksum[@]}" >  "${TargetLocation}/Checksum-${DATE}.txt"
echo "Number of Files:${#ListWithChecksum[@]}"
cat ${TargetLocation}/Checksum-${DATE}.txt

echo "###"
echo "### Create Backup"
echo "###"
echo "Create tar.gz"
tar cpzv --keep-directory-symlink --no-recursion -f "${TargetLocation}/${BACKUP_NAME}-${DATE}.tar.gz" -T "${TargetLocation}/ListOfFiles-${DATE}.txt"

unset IFS
echo "###"
echo "### Validate Backup"
echo "###"

if [ -f "${TargetLocation}/${BACKUP_NAME}-${DATE}.tar.gz" ]; 
then
        chown admin:plcnext ${TargetLocation}/${BACKUP_NAME}-${DATE}.tar.gz
        echo "Contents of Backup:"
        tar tvP -f "${TargetLocation}/${BACKUP_NAME}-${DATE}.tar.gz" | grep "/$"     
else
        echo "No backup created please fix your input data."
        exit 1
fi

###
### StoreBackup Remotly
###
