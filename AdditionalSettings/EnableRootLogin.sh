#!/bin/bash
# PermitRootLogin yes
# OLD: #PermitRootLogin yes
# NEW: PermitRootLogin yes
echo OLD:
cat /etc/ssh/sshd_config |grep PermitRootLogin
sed -i.backup -E "s/#.*PermitRootLogin/PermitRootLogin yes#/g" /etc/ssh/sshd_config 
echo NEW:
cat /etc/ssh/sshd_config |grep PermitRootLogin
