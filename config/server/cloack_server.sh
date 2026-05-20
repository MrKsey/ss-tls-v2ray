#!/bin/bash
# description: shadowsocks+cloack server

# Source function library.
. $CONFIG_PATH/.config.env

start() {
    cloack-server -c /etc/shadowsocks/server/ckserver.json &
}

stop() {
    pkill -f "^"cloack-server
}

status() {
    STATUS=$(netstat -tulpn | grep cloack-server); [ -z "$STATUS" ] && \
    printf "${RED}Server CLOACK is not started.${NC}\nThe network port ${RED}$CLOACK_SERVER_PORT${NC} may already be in use. Change port parameter ${RED}BindAddr${NC} in ../server/${RED}ckserver.json${NC} and restart server\n" || 
    printf "${GREEN}Server CLOACK is running:${NC}\n"; netstat -tulpn | grep cloack-server
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