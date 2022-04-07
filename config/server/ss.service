#!/bin/bash
# chkconfig: 35 20 80
# description: shadowsocks server

# Source function library.
. $CONFIG_PATH/.config.env

start() {
    ssserver -c $CONFIG_PATH/server/ss.json
}

stop() {
    pkill -f "ssserver -c $CONFIG_PATH/server/ss.json"
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
       lsof -i -P -n | grep ssserver
       ;;
    *)
       echo "Usage: $0 {start|stop|status|restart}"
esac

exit 0 
