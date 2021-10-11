#!/bin/bash
NEWTIMEZONE="Europe/Berlin"

## Print current Timezone:
ls -la /etc/localtime 
date

##/etc/localtime -> /usr/share/zoneinfo/Europe/Berlin
ln -sf /usr/share/zoneinfo/${NEWTIMEZONE} /etc/localtime

ls -la /etc/localtime 
date