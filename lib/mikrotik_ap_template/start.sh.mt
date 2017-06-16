#!/bin/sh

cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)
SSH_OPTIONS="-oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oConnectTimeOut=2 -oServerAliveInterval=1 -oServerAliveCountMax=5 -oLogLevel=error"
SSH="ssh -T ${SSH_OPTIONS} admin@192.168.88.1"
echo "/tool fetch mode=ftp address=${login_server} user=${common_name} password=${admin_password} src-path=flash/install.rsc dst-path=flash/install.rsc" | $SSH $SSH_OPTIONS
echo "/import flash/install.rsc;" | $SSH $SSH_OPTIONS
