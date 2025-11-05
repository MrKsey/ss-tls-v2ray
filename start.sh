#!/bin/bash

# Trap signals for graceful shutdown container
trap "/ps_exit.sh" SIGTERM

# Start load configs
. /config.sh

# Updates
. /update.sh

# Start services
echo "$(date): Start services..."
echo
if [ ! -z "$(/etc/init.d/ss.sh status | grep "not started")" ] && [ "$SS_ENABLED" = "true" ]; then
    /etc/init.d/ss.sh start
else
    [ ! -z "$(/etc/init.d/ss.sh status | grep "not started")" ] && [ "$MODE" = "server" ] && /etc/init.d/ss.sh start
fi

if [ ! -z "$(/etc/init.d/ss-simple-tls.sh status | grep "not started")" ] && [ "$SIMPLE_TLS_ENABLED" = "true" ]; then
    /etc/init.d/ss-simple-tls.sh start
fi

if [ ! -z "$(/etc/init.d/ss-v2ray.sh status | grep "not started")" ] && [ "$V2RAY_ENABLED" = "true" ]; then
    /etc/init.d/ss-v2ray.sh start
fi

sleep 5
echo " "
echo "==========================================================================="
echo "$(date): Services status:"
echo "==========================================================================="
/etc/init.d/ss.sh status
echo "==========================================================================="
/etc/init.d/ss-simple-tls.sh status
echo "==========================================================================="
/etc/init.d/ss-v2ray.sh status
echo " "

# Start monitoring config.ini
# echo "==========================================================================="
# echo "Start monitoring config.ini..."
# echo " "
# ls /etc/shadowsocks/config.ini | entr -npsz 'echo "$(date): config.ini changed. Applying new settings..." && /config.sh && /restart_svc.sh' &

# endless work...
tail -f /dev/null & wait ${!}

