# PLCnext Utility Scripts

This repository holds a collection of useful PLCnext related scripts.

# Diagnosis
| Root | Short Description         | Link                                                                  |
|----- | :-------------------------|:---------------------------------------------------------------------:|
| []   | Check active Partition    | [checkActivePartition.sh](Diagnostic/checkActivePartition.sh)         |
| []   | Check Kernel Flags        | [CheckKernelFlags.sh](Diagnostic/CheckKernelFlags.sh)                 |
| []   | Record Network settings   | [CheckNetworkSettings.sh](Diagnostic/CheckNetworkSettings.sh)         |
| [o/r]   | Find Listening Ports      | [CheckOpenSockets.sh](Diagnostic/CheckOpenSockets.sh)                 |
| []   | Remote GDB using bash     | [CppGDBstartDebug.sh.sh](Diagnostic/CppGDBstartDebug.sh.sh)           |
| []   | CyclicLogs                | [CyclicLogs.sh](Diagnostic/CyclicLogs.sh)                             |
| []   | Log RAM status            | [MemoryLog.sh](Diagnostic/MemoryLog.sh)                               |
| []   | Search for Large Files    | [SearchLargeFiles.sh](Diagnostic/SearchLargeFiles.sh)                 |

EXAMPLE:
```bash
./checkOpenSockets.sh PORT TYPE
./checkOpenSockets.sh "191" "udp"
```

# Backups
| Root | Short Description         | Link                                                                  |
|----- | :-------------------------|:---------------------------------------------------------------------:|
| [r]  | Backup SD with license    | [backupSD.sh] (Backup/backupSD.sh)                                    |
| [r]  | Restore Backup            | [restoreBackup.sh](Backup/restoreBackup.sh)                           |

EXAMPLE:
```bash
Backup/backupSD.sh "DATAPATH" "StoreBackupAt"
Backup/restoreBackup.sh "TargetDirectory" "BackupLocation"
...
Backup/backupSD.sh "/media/rfs/rw/" "/media/rfs/rw/"
Backup/restoreBackup.sh "/media/rfs/rw/" "/media/rfs/rw/backup-2021-09-10.tar"
```

# Set additional settings
| Root | Short Description         | Link                                                                  |
|----- | :-------------------------|:---------------------------------------------------------------------:|
| [r]  | Change Timezone           | [ChangeTimezone.sh](AdditionalSettings/ChangeTimezone.sh)             |
| [s]  | create root user          | [createRootUser.sh ](AdditionalSettings/createRootUser.sh )           |
| [r]  | Enable Root SSH-Login     | [EnableRootLogin.sh](AdditionalSettings/EnableRootLogin.sh)           |
| [r]  | Add Temporary IP and GW.  | [AddIPSettings.sh](AdditionalSettings/AddIPSettings.sh)               |

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