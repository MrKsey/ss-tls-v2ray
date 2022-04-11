#!/bin/bash
# description: shadowsocks+v2ray client

# Source function library.
. $CONFIG_PATH/.config.env

start() {
    sslocal -c $CONFIG_PATH/client/ss-v2ray.json &
}

stop() {
    pkill -f "sslocal -c $CONFIG_PATH/client/ss-v2ray.json"
}

status() {
    STATUS=$(lsof -n -P -i | grep "sslocal" | grep ":$V2RAY_LOCAL_PORT"); [ -z "$STATUS" ] && \
    printf "${RED}Client SS+V2RAY is not started.${NC}\nThe network port ${RED}$V2RAY_LOCAL_PORT${NC} may already be in use. Change port parameter ${RED}local_port${NC} in ../client/${RED}ss-v2ray.json${NC} and restart client\n" || 
    printf "${GREEN}Client SS+V2RAY is running:${NC} remote server is $SS_SERVER_ADDR:$V2RAY_SERVER_PORT\n"; lsof -n -P -i | grep "sslocal" | grep ":$V2RAY_LOCAL_PORT"
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
