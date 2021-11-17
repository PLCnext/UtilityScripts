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
options=("SD Licence" "DeviceData" "PCWE" "Upperdir" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "SD Licence")               
            echo "Restore Licence."
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

        "Exit")               
            exit 1        
            break
        ;;

        *) echo "invalid option $REPLY";;
    esac
done