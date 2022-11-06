#!/bin/bash

echo " "
echo "=================================================="
echo "$(date): restart_svc.sh started"
echo "=================================================="
echo " "

if [ -s /etc/shadowsocks/.config.env ]; then
    set -a; . /etc/shadowsocks/.config.env; set +a
fi

# Restart ShadowSocks
if [ "$SS_ENABLED" = "true" ]; then
    /etc/init.d/ss.sh restart
else
    if [ "$MODE" = "server" ]; then
        /etc/init.d/ss.sh restart
    else
        /etc/init.d/ss.sh stop
    fi
fi

# Restart Simple TLS
if [ "$SIMPLE_TLS_ENABLED" = "true" ]; then
    /etc/init.d/ss-simple-tls.sh restart
else
    /etc/init.d/ss-simple-tls.sh stop
fi

# Restart V2RAY
if [ "$V2RAY_ENABLED" = "true" ]; then
    /etc/init.d/ss-v2ray.sh restart
else
    /etc/init.d/ss-v2ray.sh stop
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

# Start new monitoring config.ini
ls /etc/shadowsocks/config.ini | entr -npsz 'echo " " && echo "===========================================================================" \
&& echo "$(date): config.ini changed. Applying new settings..." && echo " " \
&& /config.sh && /restart_svc.sh' &

echo " "
echo "=================================================="
echo "$(date): restart_svc.sh finished"
echo "=================================================="
echo " "
