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
    printf "${RED}Client ShadowSocks is not started.${NC}\nThe network port ${RED}$SS_LOCAL_PORT${NC} may already be in use. Change port parameter ${RED}local_port${NC} in ../client/${RED}ss.json${NC} and restart client\n" || 
    printf "${GREEN}Client ShadowSocks is running:${NC}\n"; lsof -n -P -i | grep "sslocal" | grep ":$SS_LOCAL_PORT"; echo; printf "Remote server: ${GREEN}$SS_SERVER_ADDR:$SS_SERVER_PORT${NC}\n"
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
       sleep 2
       start
       ;;
    status)
       status
       ;;
    *)
       echo "Usage: $0 {start|stop|status|restart}"
esac

exit 0
