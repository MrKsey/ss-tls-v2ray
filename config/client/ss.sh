#!/bin/bash
# description: shadowsocks client

# Source function library.
. $CONFIG_PATH/.config.env

start() {
    sslocal -c $CONFIG_PATH/client/ss.json &
}

stop() {
    pkill -f "sslocal -c $CONFIG_PATH/client/ss.json"
}

status() {
    STATUS=$(lsof -i -P -n | grep sslocal); [ -z "$STATUS" ] && \
    echo "Client sslocal is not started. The network port $SS_SERVER_PORT may already be in use. Change port parameter server_port in ../server/ss.json and restart server" || 
    echo "Server sslocal is running:"; lsof -i -P -n | grep ssserver | grep $SS_SERVER_PORT
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
