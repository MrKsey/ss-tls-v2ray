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
    STATUS=$(lsof -n -P -i | grep "sslocal" | grep ":$SS_LOCAL_PORT"); [ -z "$STATUS" ] && \
    printf "${RED}Client ShadowSocks is not started.${NC}\n The network port $SS_LOCAL_PORT may already be in use. Change port parameter local_port in ../client/ss.json and restart client\n" || 
    printf "${GREEN}Client ShadowSocks is running:${NC}\n"; lsof -n -P -i | grep "sslocal" | grep ":$SS_LOCAL_PORT"
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
