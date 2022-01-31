#!/bin/bash
# ******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************
CURRENT=$(pwd)
TargetDirectory="$1"
BackupLocation="$2"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
## Set the directories for the backup
. ${SCRIPT_DIR}/../Backup/backupSettings.sh

if [ "$1" == "" ]; then
    echo "please add backup location as argument"
    echo "Example: 
    ./restoreBackup.sh '/media/rfs/rw' '/media/rfs/rw/backup-2021-09-10.tar'"
    exit 1
fi

if [ "$(whoami)" != "root" ]; then
        echo "please use ROOT to restore a backup";
        exit 255;
fi

echo "Contents of Backup: "
tar -tvf "${BackupLocation}"

echo 'Choose all the directories you wish to restore.'
PS3="Select your choice: "
options=("SD Licence" \
"DeviceData" \
"PCWE" \
"Upperdir" \
"Containers" \
"Exit")
select opt in "${options[@]}"
do
    case $opt in
        "SD Licence")               
            echo "Restoring Licence"        

            CURRENT_SD_LICENCE=($(ls /media/rfs/externalsd/licence))
            BACKUP_SD_LICENCE=($(tar -tf "${BackupLocation}" licence  | sed 's/licence\///' | sed -r '/^\s*$/d'))

            echo "CURRENT SD LICENCE:  ${CURRENT_SD_LICENCE[@]}"
            echo "BACKUP SD LICNENCE:  ${BACKUP_SD_LICENCE[@]}"
            if [ ${CURRENT_SD_LICENCE[0]} != ${BACKUP_SD_LICENCE[1]} ] | [ ${CURRENT_SD_LICENCE[1]} != ${BACKUP_SD_LICENCE[0]} ]; then
                ## This is not comparing the actuall licence but the randomly generated filename
                ## is a pretty good indicator that the licence file does not belong to this device.
                echo "####ATTENTION####"
                echo "Backup differs from current device significantly"
                echo "$CURRENT_SD_LICENCE != $BACKUP_SD_LICENCE"
                echo "Are you sure this is the same Device this Backup was created from?"                           
            fi

            echo "Restoring this backup might void an SD-Cards License if written to a different SD-Card it was created from."            
            read -r -p "Are you sure? [y/N] " response
            tar --same-owner -xvf "${BackupLocation}" -C "$TargetDirectory" licence && echo "Done restoring License"
        ;;

        "DeviceData")
            echo "Restoring DeviceData."
            echo "Restoring this backup might destroy your PLC if written to a different PLC it was created from."
            CURRENT_SERIAL_NUMBER=$(cat /etc/device_data/phoenixsign/production_data | grep "OEM_SERIAL=" | sed 's/;//' )
            BACKUP_SERIAL_NUMBER=$(tar xf "${BackupLocation}" device_data/phoenixsign/production_data -O |  grep "OEM_SERIAL=" | sed 's/;//')

            echo "CURRENT SN: $CURRENT_SERIAL_NUMBER"
            echo "BACKUP SN: $BACKUP_SERIAL_NUMBER"
        	
            if [ $CURRENT_SERIAL_NUMBER != $BACKUP_SERIAL_NUMBER ]; then
                echo "####ATTENTION####"
                echo "Backup SN differs from Device SN"
                echo "$BACKUP_SERIAL_NUMBER != $CURRENT_SERIAL_NUMBER"
                echo "Are you sure this is the same Device this Backup was created from?"                
            fi

            read -r -p "Continue restoring backup to device [Yes/N]" response
            tar --same-owner -xvf "${BackupLocation}" -C "/etc" device_data && echo "Done restoring DeviceData"
        ;;

        "PCWE")
            echo "Restore PCWE Folder from Backup."
            tar --same-owner -xvf "${BackupLocation}" -C "$TargetDirectory" upperdir/opt/plcnext/projects/PCWE && echo "Done restoring PCWE"      
        ;;

        "Upperdir")
            echo "Restore Upperdir"
            tar --same-owner -xvf "${BackupLocation}" -C "$TargetDirectory" upperdir && echo "Done restoring Upperdir"     
        ;;

        "Containers")
            echo "Restoring Containers"
            echo "This just restores the current state of the saved Container as an Image!"
            echo "You still need to Setup the Container again after restoring this backup"
            echo "podman run -v XX -p xxx ... "
            tar --same-owner -xvf "${BackupLocation}" -C "$TargetDirectory" Containers && echo "Done restoring Container.tar"
            CONTAINERS=($(ls $TargetDirectory/Containers))
            for CONTAINER in "${CONTAINERS[@]}"
            do
                echo "Importing $CONTAINER"
                $CONTAINER_ENGINE import $TargetDirectory/Containers/$CONTAINER  
                rm $TargetDirectory/Containers/$CONTAINER                 
            done && echo "Done"
        ;;

        "Exit")               
            exit 1        
            break
        ;;

        *) echo "invalid option $REPLY";;
    esac
done