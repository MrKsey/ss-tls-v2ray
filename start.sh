#!/bin/sh

# Start load configs
. $CONFIG_PATH/config.sh

# Updates
. $CONFIG_PATH/update.sh

# Scheduled updates
if [ ! -z "$UPDATE_SCHEDULE" ]; then
    echo "$UPDATE_SCHEDULE $CONFIG_PATH/update.sh >> /var/log/cron.log 2>&1" | crontab -
    cron -f >> /var/log/cron.log 2>&1&
fi

# Start services
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
echo
echo "==========================================================================="
echo "$(date): Services status:"
echo "==========================================================================="
/etc/init.d/ss.sh status
echo "==========================================================================="
/etc/init.d/ss-simple-tls.sh status
echo "==========================================================================="
/etc/init.d/ss-v2ray.sh status

# endless work...
tail -f /dev/null
