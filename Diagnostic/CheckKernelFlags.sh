#!/bin/bash

FLAG=LAN
echo "Check Kernel Flags for:{FLAG}"
cat /proc/config.gz | gunzip | grep $FLAG
