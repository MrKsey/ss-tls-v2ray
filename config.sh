#!/bin/sh

# Start load configs
if [ -s $CONFIG_PATH/config.ini ]; then
    # Load config from config.ini
    sed -i -e "s/\r//g" $CONFIG_PATH/config.ini
	. $CONFIG_PATH/config.ini && export $(grep -E ^[a-zA-Z] $CONFIG_PATH/config.ini | cut -d= -f1)
    
    # Sync configuration files with github
    svn checkout $GIT_URL/trunk/config $CONFIG_PATH
    # chown -R root:root $CONFIG_PATH
    # chmod -R 644 $CONFIG_PATH

    if [ "$MODE" = "client" ] && [ -s $CONFIG_PATH/_CLIENT.txt ]; then
        # Load config from _CLIENT.txt
        sed -i -e "s/\r//g" $CONFIG_PATH/_CLIENT.txt
        . $CONFIG_PATH/_CLIENT.txt && export $(grep -E ^[a-zA-Z] $CONFIG_PATH/_CLIENT.txt | cut -d= -f1)
    fi
else
# First time run.
    # Download configuration files from github
    svn checkout $GIT_URL/trunk/config $CONFIG_PATH
    # chown -R root:root $CONFIG_PATH
    # chmod -R 644 $CONFIG_PATH

    if [ -s $CONFIG_PATH/config.ini ]; then
        # Load config from config.ini
        sed -i -e "s/\r//g" $CONFIG_PATH/config.ini
        . $CONFIG_PATH/config.ini && export $(grep -E ^[a-zA-Z] $CONFIG_PATH/config.ini | cut -d= -f1)
    else
        # If config.ini not downloaded - create empty
        touch $CONFIG_PATH/config.ini
        tail -c1 $CONFIG_PATH/config.ini | read -r _ || echo >> $CONFIG_PATH/config.ini
    fi

    if [ -s $CONFIG_PATH/_CLIENT.txt ]; then
        # Load config from _CLIENT.txt
        sed -i -e "s/\r//g" $CONFIG_PATH/_CLIENT.txt
        . $CONFIG_PATH/_CLIENT.txt && export $(grep -E ^[a-zA-Z] $CONFIG_PATH/_CLIENT.txt | cut -d= -f1)
        # if _CLIENT.txt exist - set mode of this node to client
        export MODE=client
    fi
fi


# Check vars, set defaults in config.ini ==========================

#  OS_UPDATE
[ -z "$OS_UPDATE" ] && export OS_UPDATE=true
[ "$OS_UPDATE" != "true" ] && export OS_UPDATE=false
sed -i "/^OS_UPDATE=/{h;s/=.*/=${OS_UPDATE}/};\${x;/^$/{s//OS_UPDATE=${OS_UPDATE}/;H};x}" $CONFIG_PATH/config.ini

#  UPDATE_SCHEDULE
if [ -z "$UPDATE_SCHEDULE" ]; then
    # generate update time in interval 2-4h and 0-59m 
    UPDATE_H=$(shuf -i2-4 -n1)
    UPDATE_M=$(shuf -i0-59 -n1)
    export UPDATE_SCHEDULE="\"$UPDATE_M $UPDATE_H \* \* \*\""
fi
sed -i "/^UPDATE_SCHEDULE=/{h;s/=.*/=${UPDATE_SCHEDULE}/};\${x;/^$/{s//UPDATE_SCHEDULE=${UPDATE_SCHEDULE}/;H};x}" $CONFIG_PATH/config.ini
sed -i -E "s/UPDATE_SCHEDULE=(.*)/UPDATE_SCHEDULE=\"\1\"/" $CONFIG_PATH/config.ini
sed -i "s/\"\"/\"/g" $CONFIG_PATH/config.ini

#  MODE
[ -z "$MODE" ] && export MODE=server
[ "$MODE" != "server" ] && export MODE=client
sed -i "/^MODE=/{h;s/=.*/=${MODE}/};\${x;/^$/{s//MODE=${MODE}/;H};x}" $CONFIG_PATH/config.ini

#  SS_ENABLED
[ -z "$SS_ENABLED" ] && export SS_ENABLED=true
[ "$SS_ENABLED" != "true" ] && export SS_ENABLED=false
sed -i "/^SS_ENABLED=/{h;s/=.*/=${SS_ENABLED}/};\${x;/^$/{s//SS_ENABLED=${SS_ENABLED}/;H};x}" $CONFIG_PATH/config.ini
#  SS_VER
[ -z "$SS_VER" ] && export SS_VER=latest
sed -i "/^SS_VER=/{h;s/=.*/=${SS_VER}/};\${x;/^$/{s//SS_VER=${SS_VER}/;H};x}" $CONFIG_PATH/config.ini

#  SIMPLE_TLS_ENABLED
[ -z "$SIMPLE_TLS_ENABLED" ] && export SIMPLE_TLS_ENABLED=true
[ "$SIMPLE_TLS_ENABLED" != "true" ] && export SIMPLE_TLS_ENABLED=false
sed -i "/^SIMPLE_TLS_ENABLED=/{h;s/=.*/=${SIMPLE_TLS_ENABLED}/};\${x;/^$/{s//SIMPLE_TLS_ENABLED=${SIMPLE_TLS_ENABLED}/;H};x}" $CONFIG_PATH/config.ini
#  SIMPLE_TLS_VER
[ -z "$SIMPLE_TLS_VER" ] && export SIMPLE_TLS_VER=latest
sed -i "/^SIMPLE_TLS_VER=/{h;s/=.*/=${SIMPLE_TLS_VER}/};\${x;/^$/{s//SIMPLE_TLS_VER=${SIMPLE_TLS_VER}/;H};x}" $CONFIG_PATH/config.ini
#  SIMPLE_TLS_DOMAIN
[ -z "$SIMPLE_TLS_DOMAIN" ] && export SIMPLE_TLS_DOMAIN=windowsupdate.microsoft.com
sed -i "/^SIMPLE_TLS_DOMAIN=/{h;s/=.*/=${SIMPLE_TLS_DOMAIN}/};\${x;/^$/{s//SIMPLE_TLS_DOMAIN=${SIMPLE_TLS_DOMAIN}/;H};x}" $CONFIG_PATH/config.ini

#  V2RAY_ENABLED
[ -z "$V2RAY_ENABLED" ] && export V2RAY_ENABLED=true
[ "$V2RAY_ENABLED" != "true" ] && export V2RAY_ENABLED=false
sed -i "/^V2RAY_ENABLED=/{h;s/=.*/=${V2RAY_ENABLED}/};\${x;/^$/{s//V2RAY_ENABLED=${V2RAY_ENABLED}/;H};x}" $CONFIG_PATH/config.ini
#  V2RAY_VER
[ -z "$V2RAY_VER" ] && export V2RAY_VER=latest
sed -i "/^V2RAY_VER=/{h;s/=.*/=${V2RAY_VER}/};\${x;/^$/{s//V2RAY_VER=${V2RAY_VER}/;H};x}" $CONFIG_PATH/config.ini
#  V2RAY_DOMAIN
[ -z "$V2RAY_DOMAIN" ] && export V2RAY_DOMAIN=windowsupdate.microsoft.com
sed -i "/^V2RAY_DOMAIN=/{h;s/=.*/=${V2RAY_DOMAIN}/};\${x;/^$/{s//V2RAY_DOMAIN=${V2RAY_DOMAIN}/;H};x}" $CONFIG_PATH/config.ini


# if this node is server then generate _CLIENT.txt with data for client
if [ "$MODE" = "server" ]; then
    # Create new _CLIENT.txt
    grep -E ^[a-zA-Z] $CONFIG_PATH/config.ini > $CONFIG_PATH/_CLIENT.txt
    # Change MODE to client in _CLIENT.txt
    sed -i "/^MODE=/{h;s/=.*/=client/};\${x;/^$/{s//MODE=client/;H};x}" $CONFIG_PATH/_CLIENT.txt
    
    # ShadowSocks ===============================

    # SS_SERVER_ADDR
    if [ "$SS_ENABLED" = "true" ]; then
        export SS_SERVER_ADDR=$(jq -r '."server"' $CONFIG_PATH/server/ss.json)
        [ -z "$SS_SERVER_ADDR" ] && export SS_SERVER_ADDR="0.0.0.0" && jq '."server" = "'"$SS_SERVER_ADDR"'"' $CONFIG_PATH/server/ss.json | sponge $CONFIG_PATH/server/ss.json
    else
        export SS_SERVER_ADDR=127.0.0.1
        jq '."server" = "'"$SS_SERVER_ADDR"'"' $CONFIG_PATH/server/ss.json | sponge $CONFIG_PATH/server/ss.json
    fi
    # WAN IP -> SS_SERVER_ADDR
    SERVER_WAN_IP=$(curl ifconfig.me || curl checkip.amazonaws.com || curl ifconfig.co) && export SERVER_WAN_IP=$(echo $SERVER_WAN_IP | tr -d ' ')
    [ ! -z "$SERVER_WAN_IP" ] && sed -i "/^SS_SERVER_ADDR=/{h;s/=.*/=${SERVER_WAN_IP}/};\${x;/^$/{s//SS_SERVER_ADDR=${SERVER_WAN_IP}/;H};x}" $CONFIG_PATH/_CLIENT.txt

    # SS_SERVER_PORT
    export SS_SERVER_PORT=$(jq -r '."server_port"' $CONFIG_PATH/server/ss.json)
    [ -z "$SS_SERVER_PORT" ] && export SS_SERVER_PORT=8443 && jq '."server_port" = '$SS_SERVER_PORT'' $CONFIG_PATH/server/ss.json | sponge $CONFIG_PATH/server/ss.json
    sed -i "/^SS_SERVER_PORT=/{h;s/=.*/=${SS_SERVER_PORT}/};\${x;/^$/{s//SS_SERVER_PORT=${SS_SERVER_PORT}/;H};x}" $CONFIG_PATH/_CLIENT.txt

    # SS_PASSWORD
    export SS_PASSWORD=$(jq -r '."password"' $CONFIG_PATH/server/ss.json)
    # If empty - generate new password
    [ -z "$SS_PASSWORD" ] && export SS_PASSWORD=$(openssl rand -base64 48 | tr -d /=+ | cut -c -40) && jq '."password" = "'"$SS_PASSWORD"'"' $CONFIG_PATH/server/ss.json | sponge $CONFIG_PATH/server/ss.json
    sed -i "/^SS_PASSWORD=/{h;s/=.*/=${SS_PASSWORD}/};\${x;/^$/{s//SS_PASSWORD=${SS_PASSWORD}/;H};x}" $CONFIG_PATH/_CLIENT.txt

    # SS_METHOD
    export SS_METHOD=$(jq -r '."method"' $CONFIG_PATH/server/ss.json)
    [ -z "$SS_METHOD" ] && export SS_METHOD="chacha20-ietf-poly1305" && jq '."method" = "'"$SS_METHOD"'"' $CONFIG_PATH/server/ss.json | sponge $CONFIG_PATH/server/ss.json
    sed -i "/^SS_METHOD=/{h;s/=.*/=${SS_METHOD}/};\${x;/^$/{s//SS_METHOD=${SS_METHOD}/;H};x}" $CONFIG_PATH/_CLIENT.txt
    
    # SS_MODE
    export SS_MODE=$(jq -r '."mode"' $CONFIG_PATH/server/ss.json)
    [ -z "$SS_MODE" ] && export SS_MODE="tcp_and_udp" && jq '."mode" = "'"$SS_MODE"'"' $CONFIG_PATH/server/ss.json | sponge $CONFIG_PATH/server/ss.json
    sed -i "/^SS_MODE=/{h;s/=.*/=${SS_MODE}/};\${x;/^$/{s//SS_MODE=${SS_MODE}/;H};x}" $CONFIG_PATH/_CLIENT.txt
    
    # Set workers count
    CPU_COUNT=$(lscpu | grep -E "^CPU\(s\)\:" | tr -d ' ' | cut -d ':' -f 2)
    [ $CPU_COUNT -gt 1 ] && jq '."workers" = '$CPU_COUNT'' $CONFIG_PATH/server/ss.json | sponge $CONFIG_PATH/server/ss.json
    
    # grant permanent access to bind to low-numbered ports via the setcap
    setcap "cap_net_bind_service=+eip" /usr/local/bin/ssserver
     
    # SIMPLE_TLS ===============================
     
    # SIMPLE_TLS_SERVER_PORT
    export SIMPLE_TLS_SERVER_PORT=$(grep -o -P "\-b.+?:[0-9]+" $CONFIG_PATH/server/ss-simple-tls.sh | cut -d ':' -f 2)
    sed -i "/^SIMPLE_TLS_SERVER_PORT=/{h;s/=.*/=${SIMPLE_TLS_SERVER_PORT}/};\${x;/^$/{s//SIMPLE_TLS_SERVER_PORT=${SIMPLE_TLS_SERVER_PORT}/;H};x}" $CONFIG_PATH/_CLIENT.txt
    # SS_SERVER_PORT -> ss-simple-tls.sh
    sed -i -E "s/(\-d.+?:)[0-9]+/\\1${SS_SERVER_PORT}/" $CONFIG_PATH/server/ss-simple-tls.sh

    # generate cert for domain
    if [ ! -s $CONFIG_PATH/server/simple-tls_cert.key ] || [ ! -s $CONFIG_PATH/server/simple-tls_cert.cert ]; then 
        simple-tls -gen-cert -n $SIMPLE_TLS_DOMAIN -key $CONFIG_PATH/server/simple-tls_cert.key -cert $CONFIG_PATH/server/simple-tls_cert.cert
    fi
    SIMPLE_TLS_CERT=$(simple-tls -hash-cert $CONFIG_PATH/server/simple-tls_cert.cert | cut -d ':' -f 2 | tr -d ' ')
    sed -i "/^SIMPLE_TLS_CERT=/{h;s/=.*/=${SIMPLE_TLS_CERT}/};\${x;/^$/{s//SIMPLE_TLS_CERT=${SIMPLE_TLS_CERT}/;H};x}" $CONFIG_PATH/_CLIENT.txt
    
    # grant permanent access to bind to low-numbered ports via the setcap
    setcap "cap_net_bind_service=+eip" /usr/local/bin/simple-tls

    # V2RAY ===============================
    
    # V2RAY_SERVER_PORT
    export V2RAY_SERVER_PORT=$(grep -o -P "\-localPort [0-9]+" $CONFIG_PATH/server/ss-v2ray.sh | cut -d ' ' -f 2)
    sed -i "/^V2RAY_SERVER_PORT=/{h;s/=.*/=${V2RAY_SERVER_PORT}/};\${x;/^$/{s//V2RAY_SERVER_PORT=${V2RAY_SERVER_PORT}/;H};x}" $CONFIG_PATH/_CLIENT.txt
    # SS_SERVER_PORT -> ss-v2ray.sh
    sed -i -E "s/-remotePort [0-9]+/-remotePort ${SS_SERVER_PORT}/" $CONFIG_PATH/server/ss-v2ray.sh
    
    # grant permanent access to bind to low-numbered ports via the setcap
    setcap "cap_net_bind_service=+eip" /usr/local/bin/v2ray-*
	
    chmod -R a+x $CONFIG_PATH/server/ss*.sh
    ln -s -f $CONFIG_PATH/server/ss.sh /etc/init.d/
    ln -s -f $CONFIG_PATH/server/ss-simple-tls.sh /etc/init.d/
    ln -s -f $CONFIG_PATH/server/ss-v2ray.sh /etc/init.d/
    
else
    # if _CLIENT.txt exist apply setting to client files only once
    if [ -s $CONFIG_PATH/_CLIENT.txt ]; then
        mv -f $CONFIG_PATH/_CLIENT.txt $CONFIG_PATH/_CLIENT.old.txt
        
        export CPU_COUNT=$(lscpu | grep -E "^CPU\(s\)\:" | tr -d ' ' | cut -d ':' -f 2)
        
        # ShadowSocks client ===============================
        [ ! -z "$SS_SERVER_ADDR" ] && jq '."server" = "'"$SS_SERVER_ADDR"'"' $CONFIG_PATH/client/ss.json | sponge $CONFIG_PATH/client/ss.json
        [ ! -z "$SS_SERVER_PORT" ] && jq '."server_port" = '$SS_SERVER_PORT'' $CONFIG_PATH/client/ss.json | sponge $CONFIG_PATH/client/ss.json
        [ ! -z "$SS_PASSWORD" ] && jq '."password" = "'"$SS_PASSWORD"'"' $CONFIG_PATH/client/ss.json | sponge $CONFIG_PATH/client/ss.json
        [ ! -z "$SS_METHOD" ] && jq '."method" = "'"$SS_METHOD"'"' $CONFIG_PATH/client/ss.json | sponge $CONFIG_PATH/client/ss.json
        [ $CPU_COUNT -gt 1 ] && jq '."workers" = '$CPU_COUNT'' $CONFIG_PATH/client/ss.json | sponge $CONFIG_PATH/client/ss.json
        [ ! -z "$SS_MODE" ] && jq '."mode" = "'"$SS_MODE"'"' $CONFIG_PATH/client/ss.json | sponge $CONFIG_PATH/client/ss.json
        
        # SIMPLE_TLS client ===============================
        [ ! -z "$SS_SERVER_ADDR" ] && jq '."server" = "'"$SS_SERVER_ADDR"'"' $CONFIG_PATH/client/ss-simple-tls.json | sponge $CONFIG_PATH/client/ss-simple-tls.json
        [ ! -z "$SIMPLE_TLS_SERVER_PORT" ] && jq '."server_port" = '$SIMPLE_TLS_SERVER_PORT'' $CONFIG_PATH/client/ss-simple-tls.json | sponge $CONFIG_PATH/client/ss-simple-tls.json
        [ ! -z "$SS_PASSWORD" ] && jq '."password" = "'"$SS_PASSWORD"'"' $CONFIG_PATH/client/ss-simple-tls.json | sponge $CONFIG_PATH/client/ss-simple-tls.json
        [ ! -z "$SS_METHOD" ] && jq '."method" = "'"$SS_METHOD"'"' $CONFIG_PATH/client/ss-simple-tls.json | sponge $CONFIG_PATH/client/ss-simple-tls.json
        [ $CPU_COUNT -gt 1 ] && jq '."workers" = '$CPU_COUNT'' $CONFIG_PATH/client/ss-simple-tls.json | sponge $CONFIG_PATH/client/ss-simple-tls.json
        sed -i -E "s/(cert-hash=)[a-zA-Z0-9]+(;)/\\1${SIMPLE_TLS_CERT}\\2/" $CONFIG_PATH/client/ss-simple-tls.json
        
        # V2RAY client ====================================
        [ ! -z "$SS_SERVER_ADDR" ] && jq '."server" = "'"$SS_SERVER_ADDR"'"' $CONFIG_PATH/client/ss-v2ray.json | sponge $CONFIG_PATH/client/ss-v2ray.json
        [ ! -z "$V2RAY_SERVER_PORT" ] && jq '."server_port" = '$V2RAY_SERVER_PORT'' $CONFIG_PATH/client/ss-v2ray.json | sponge $CONFIG_PATH/client/ss-v2ray.json
        [ ! -z "$SS_PASSWORD" ] && jq '."password" = "'"$SS_PASSWORD"'"' $CONFIG_PATH/client/ss-v2ray.json | sponge $CONFIG_PATH/client/ss-v2ray.json
        [ ! -z "$SS_METHOD" ] && jq '."method" = "'"$SS_METHOD"'"' $CONFIG_PATH/client/ss-v2ray.json | sponge $CONFIG_PATH/client/ss-v2ray.json
        [ $CPU_COUNT -gt 1 ] && jq '."workers" = '$CPU_COUNT'' $CONFIG_PATH/client/ss-v2ray.json | sponge $CONFIG_PATH/client/ss-v2ray.json
    fi
	
    export SS_SERVER_ADDR=$(jq -r '."server"' $CONFIG_PATH/client/ss.json)
    export SS_SERVER_PORT=$(jq -r '."server_port"' $CONFIG_PATH/client/ss.json)
    export SS_LOCAL_PORT=$(jq -r '."local_port"' $CONFIG_PATH/client/ss.json)
	
    export SIMPLE_TLS_SERVER_PORT=$(jq -r '."server_port"' $CONFIG_PATH/client/ss-simple-tls.json)
    export SIMPLE_TLS_LOCAL_PORT=$(jq -r '."local_port"' $CONFIG_PATH/client/ss-simple-tls.json)
	
    export V2RAY_SERVER_PORT=$(jq -r '."server_port"' $CONFIG_PATH/client/ss-v2ray.json)
	export V2RAY_LOCAL_PORT=$(jq -r '."local_port"' $CONFIG_PATH/client/ss-v2ray.json)
	
    chmod -R a+x $CONFIG_PATH/client/ss*.sh
    ln -s -f $CONFIG_PATH/client/ss.sh /etc/init.d/
    ln -s -f $CONFIG_PATH/client/ss-simple-tls.sh /etc/init.d/
    ln -s -f $CONFIG_PATH/client/ss-v2ray.sh /etc/init.d/

fi

# Save ENV VARS to file
env | grep -v UPDATE_SCHEDULE | awk 'NF {sub("=","=\"",$0); print ""$0"\""}' > $CONFIG_PATH/.config.env && chmod 644 $CONFIG_PATH/.config.env

# Colorize bash output
echo "RED='\033[0;31m'" >> $CONFIG_PATH/.config.env
echo "GREEN='\033[0;32m'" >> $CONFIG_PATH/.config.env
echo "NC='\033[0m'" >> $CONFIG_PATH/.config.env
