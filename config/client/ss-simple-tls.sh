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
    printf "${RED}Client SS+Simple-TLS is not started.${NC}\nThe network port ${RED}$SIMPLE_TLS_LOCAL_PORT${NC} may already be in use. Change port parameter ${RED}local_port${NC} in ../client/${RED}ss-simple-tls.json${NC} and restart client\n" || 
    printf "${GREEN}Client SS+Simple-TLS is running:${NC}\n"; lsof -n -P -i | grep "sslocal" | grep ":$SIMPLE_TLS_LOCAL_PORT"
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
