#!/bin/bash
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
            tar --same-owner -xf "${BackupLocation}" -C "$TargetDirectory" licence
        ;;

        "DeviceData")
            echo "Restore DeviceData."
            echo "Restoring this backup might destroy PLC data if written to a different PLC it was created from."  
            read -r -p "Are you sure? [y/N] " response           
            tar --same-owner -xf "${BackupLocation}" -C "/etc" device_data       
        ;;

        "PCWE")
            echo "Restore PCWE Folder from Backup."
            tar --same-owner -xf "${BackupLocation}" -C "$TargetDirectory" upperdir/opt/plcnext/projects/PCWE      
        ;;

        "Upperdir")
            echo "Restore Upperdir"
            tar --same-owner -xf "${BackupLocation}" -C "$TargetDirectory" upperdir      
        ;;

        "Exit")               
                exit 1        
                break
        ;;

        *) echo "invalid option $REPLY";;
    esac
done