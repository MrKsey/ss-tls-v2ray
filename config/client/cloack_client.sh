#!/bin/bash
# description: shadowsocks+cloack server

# Source function library.
. $CONFIG_PATH/.config.env

start() {
    cloack-client -s $SS_SERVER_ADDR -p $CLOACK_SERVER_PORT -i 127.0.0.1 -l $CLOACK_LOCAL_PORT -c /etc/shadowsocks/client/ckclient.json &
    ss-redir -c /etc/shadowsocks/client/ss-cloack.json &
}

stop() {
    pkill -f "[s]s-redir -c /etc/shadowsocks/client/ss-cloack.json"
    pkill -f "^"cloack-client
}

status() {
    STATUS=$(netstat -tulpn | grep cloack-client); [ -z "$STATUS" ] && \
    printf "${RED}Client CLOACK is not started.${NC}\nThe network port ${RED}$CLOACK_LOCAL_PORT${NC} may already be in use. Change port parameter ${RED}-l [port]${NC} in ../client/${RED}cloack_client.sh${NC} and restart client\n" || 
    printf "${GREEN}Client CLOACK is running:${NC}\n"; netstat -tulpn | grep cloack-client
    
    STATUS=$(netstat -tulpn | grep $(pgrep -f "ss-redir -c /etc/shadowsocks/ss-cloack.json")); [ -z "$STATUS" ] && \
    printf "${RED}Client Shadowsocks-CLOACK is not started.${NC}\nThe network port ${RED}$SS_LOCAL_PORT${NC} may already be in use. Change port parameter ${RED}local_port${NC} in ../client/${RED}ss-cloack.json${NC} and restart client\n" || 
    printf "${GREEN}Client CLOACK is running:${NC}\n"; netstat -tulpn | grep cloack-client
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