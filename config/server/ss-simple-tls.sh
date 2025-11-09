#!/bin/bash
# description: shadowsocks+simple-tls server

# Source function library.
. $CONFIG_PATH/.config.env

start() {
    simple-tls -b :443 -d 127.0.0.1:8443 -s -key $CONFIG_PATH/server/simple-tls_cert.key -cert $CONFIG_PATH/server/simple-tls_cert.cert "$GRPC_SERVER" &
}

stop() {
    pkill -f "^"simple-tls
}

status() {
    STATUS=$(netstat -tulpn | grep simple-tl); [ -z "$STATUS" ] && \
    printf "${RED}Server SIMPLE-TLS is not started.${NC}\nThe network port ${RED}$SIMPLE_TLS_SERVER_PORT${NC} may already be in use. Change port parameter ${RED}-b${NC} in ../server/${RED}ss-simple-tls.sh${NC} and restart server\n" || 
    printf "${GREEN}Server SIMPLE-TLS is running:${NC}\n"; netstat -tulpn | grep simple-tl
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
