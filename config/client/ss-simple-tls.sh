#!/bin/bash
# description: shadowsocks+simple-tls client

# Source function library.
. $CONFIG_PATH/.config.env

start() {
    sslocal -c $CONFIG_PATH/client/ss-simple-tls.json &
}

stop() {
    pkill -f "sslocal -c $CONFIG_PATH/client/ss-simple-tls.json"
}

status() {
    STATUS=$(lsof -i -P -n | grep sslocal); [ -z "$STATUS" ] && \
    echo "Client simple-tls is not started. Check the ports." || echo "Client simple-tls is running:"; lsof -i -P -n | grep sslocal
}

case "$1" in 
    start)
       start
       ;;
    stop)
       stop
       ;;
    restart)
       stop
       start
       ;;
    status)
       status
       ;;
    *)
       echo "Usage: $0 {start|stop|status|restart}"
esac

exit 0
