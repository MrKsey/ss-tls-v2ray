#!/bin/bash

echo " "
echo "=================================================="
echo " "
# Graceful shutdown container
echo "$(date): Graceful shutdown container ..."

pkill -15 cron

/etc/init.d/ss-simple-tls.sh stop
/etc/init.d/ss-v2ray.sh stop
/etc/init.d/ss.sh stop

sync

pkill -15 tail
pkill -15 bash
echo " "
echo "=================================================="
