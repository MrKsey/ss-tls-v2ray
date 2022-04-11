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
    STATUS=$(lsof -n -P -i | grep "sslocal" | grep ":$SIMPLE_TLS_LOCAL_PORT"); [ -z "$STATUS" ] && \
    echo "Client sslocal is not started. The network port $SIMPLE_TLS_LOCAL_PORT may already be in use. Change port parameter local_port in ../client/ss-simple-tls.json and restart client" || 
    echo "Client sslocal is running:"; lsof -n -P -i | grep "sslocal" | grep ":$SIMPLE_TLS_LOCAL_PORT"
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