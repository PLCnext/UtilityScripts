# PLCnext Utility Scripts

This repository holds a collection of useful PLCnext related scripts to diagnose or modify your PLCnext Controll settings.

# Attention!
Please keep in mind that some of these scripts should not be executed during runtime as these might have an impact on your application!
Please always read the scripts before executing it on any device. Some scripts require individualised modifications.
When in doubt please open an Issue here, at the www.PLCnext-Community.net or contact your local subsidiary for support.

## Compatibility
Firmware Compatibility 2020 - 2021

# How To Use

```bash
ssh admin@PLC
git clone https://github.com/PLCnext/UtilityScripts.git
```

## Diagnosis
| Permissions | Short Description         | Link                                                           |
|------------ | :-------------------------|:--------------------------------------------------------------:|
| [admin]     | Check active Partition    | [checkActivePartition.sh](Diagnostic/checkActivePartition.sh)  |
| [admin]   | Check Kernel Flags        | [CheckKernelFlags.sh](Diagnostic/CheckKernelFlags.sh)            |
| [admin]   | Record Network settings   | [CheckNetworkSettings.sh](Diagnostic/CheckNetworkSettings.sh)    |
| [admin/root]   | Find Listening Ports      | [CheckOpenSockets.sh](Diagnostic/CheckOpenSockets.sh)       |
| [admin]   | Remote GDB using bash     | [CppGDBstartDebug.sh.sh](Diagnostic/CppGDBstartDebug.sh)         |
| [admin]   | CyclicLogs                | [CyclicLogs.sh](Diagnostic/CyclicLogs.sh)                        |
| [admin]   | Log RAM status            | [MemoryLog.sh](Diagnostic/MemoryLog.sh)                          |
| [admin]   | Search for Large Files    | [SearchLargeFiles.sh](Diagnostic/SearchLargeFiles.sh)            |

EXAMPLE:

```bash
Used on PC to remote control a PLC.
./Diagnostic/CppGDBstartDebug.sh

ssh admin@PLC

./Diagnostic/checkActivePartition.sh

./Diagnostic/CheckKernelFlags.sh

./Diagnostic/CheckNetworkSettings.sh

#./Diagnostic/CheckOpenSockets.sh PORT TYPE
./Diagnostic/CheckOpenSockets.sh "191" "udp"

./Diagnostic/CyclicLogs.sh

./Diagnostic/MemoryLog.sh

./Diagnostic/SearchLargeFiles.sh
```

## Backups
| Permissions | Short Description         | Link                                         |
|------------ | :-------------------------|:--------------------------------------------:|
| [root]      | Backup SD with license    | [backupSD.sh](Backup/backupSD.sh)           |
| [root]      | Restore Backup            | [restoreBackup.sh](Backup/restoreBackup.sh)  |

EXAMPLE:
```bash
./Backup/backupSD.sh "DATAPATH" "StoreBackupAt"
./Backup/restoreBackup.sh "TargetDirectory" "BackupLocation"
...

...
Backup/backupSD.sh "/media/rfs/rw/" "/media/rfs/rw/"
# Follow Dialog to create Backup
# 1: 'Choose the kind of Backup you want to create.'
# "Upperdir" 
# "PCWE Project only" 
# "Changes done via FW Services" 
# "Continue" 
# "Exit"

# 2: 'Do you wish to add stored licenses and PLC device data to this backup?'
# Multiple choices can be made.
# "Don't Store Licence" 
# "Store Licence" 
# "Don't Store DeviceData" 
# "Store DeviceData" 
# "Continue" 
# "Exit"

Backup/restoreBackup.sh "/media/rfs/rw/" "/media/rfs/rw/backup-2021-09-10.tar"
# 'Choose all the directories you wish to restore.'
# "SD Licence" 
# "DeviceData" 
# "PCWE" 
# "Upperdir" 
# "Exit"
```

## Set additional settings
| Permissions | Short Description     | Link                                                               |
|----- | :----------------------------|:------------------------------------------------------------------:|
| [root]  | Change Timezone           | [ChangeTimezone.sh](AdditionalSettings/ChangeTimezone.sh)          |
| [sudo]  | create root user          | [createRootUser.sh ](AdditionalSettings/createRootUser.sh )        |
| [root]  | Enable Root SSH-Login     | [EnableRootLogin.sh](AdditionalSettings/EnableRootLogin.sh)        |
| [root]  | Add Temporary IP and GW.  | [AddIPSettings.sh](AdditionalSettings/AddIPSettings.sh)            |

EXAMPLE:
```bash
# Modify AddIpSettings File to add your needed Settings.
# NEWIP="192.168.188.5"
# SUBNET="24"
# ADAPTER="eth0"
# DEFAULTGW="192.168.188.1"
# NAMESERVER="nameserver 1.1.1.1"

./AdditionalSettings/AddIPSettings.sh
```
