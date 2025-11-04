#!/bin/bash
# description: shadowsocks+v2ray server

# Source function library.
. $CONFIG_PATH/.config.env

start() {
    v2ray -server -host $V2RAY_DOMAIN -localAddr 0.0.0.0 -localPort 80 -remoteAddr 127.0.0.1 -remotePort 8443 -loglevel none &
}

stop() {
    pkill -f "^"v2ray
}

status() {
    STATUS=$(netstat -tulpn | grep v2ray); [ -z "$STATUS" ] && \
    printf "${RED}Server V2RAY is not started.${NC}\nThe network port ${RED}$V2RAY_SERVER_PORT${NC} may already be in use. Change port parameter ${RED}-localPort${NC} in ../server/${RED}ss-v2ray.sh${NC} and restart server\n" || 
    printf "${GREEN}Server V2RAY is running:${NC}\n"; netstat -tulpn | grep v2ray
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
