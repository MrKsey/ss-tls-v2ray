#!/bin/bash

echo " "
echo "=================================================="
echo "$(date): update.sh started"
echo "=================================================="
echo " "

if [ -s /etc/shadowsocks/.config.env ]; then
    set -a; . /etc/shadowsocks/.config.env; set +a
fi

# Update OS
if [ "$OS_UPDATE" = "true" ]; then
    echo "$(date): Start checking for OS updates ..."
    apt-get update && apt-get upgrade -y && apt-get purge -y -q --auto-remove
    echo "$(date): Finished checking for OS updates."
fi

mkdir -p /tmp/ss && cd /tmp/ss

# Update ShadowSocks
SS_VER=$([ "$SS_VER" != "latest" ] && echo tags/$SS_VER || echo $SS_VER)
SS_LOCAL_VER=$(/usr/local/bin/ssserver --version | cut -d ' ' -f 2)
SS_GIT_VER=$(curl -f -s $SS_URL/$SS_VER | jq -r '."tag_name"' | sed -E "s/^[a-zA-Z]//")
echo "$(date): Start checking for ShadowSocks updates ..."
if [ ! -z "$SS_GIT_VER" ] && [ "$SS_LOCAL_VER" != "$SS_GIT_VER" ]; then
    echo "$(date): Updating ShadowSocks to version $SS_GIT_VER ..."
    wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/ss.tar.xz --tries=3 $(\
    curl -s $SS_URL/$SS_VER | grep -o -E 'http.+\w+' | grep -i "$(uname)" | grep -i "gnu" | grep -i -v "sha256" | \
    grep -i -E "$(dpkg --print-architecture | sed "s/amd64/x86_64/g" | sed "s/arm64/aarch64/g" | sed -E "s/armhf/arm.+eabihf/g")")
    if [ $? -eq 0 ]; then
        tar -xf ss.tar.xz --directory /usr/local/bin
        chmod a+x /usr/local/bin/*
        SS_LOCAL_VER=$(/usr/local/bin/ssserver --version | cut -d ' ' -f 2)
        echo "$(date): ShadowSocks updated to version $SS_LOCAL_VER"
        if [ "$SS_ENABLED" = "true" ]; then
            /etc/init.d/ss.sh restart
            sleep 3
            /etc/init.d/ss.sh status
        else
            [ "$MODE" = "server" ] && /etc/init.d/ss.sh restart
            sleep 3
            /etc/init.d/ss.sh status
        fi
    else
        echo "$(date): Update ShadowSocks failed. Check update source url: $SS_URL/$SS_VER"
    fi
else
    echo "$(date): ShadowSocks version $SS_LOCAL_VER is latest. Nothing to update."
fi

# Update Simple TLS
SIMPLE_TLS_VER=$([ "$SIMPLE_TLS_VER" != "latest" ] && echo tags/$SIMPLE_TLS_VER || echo $SIMPLE_TLS_VER)
SIMPLE_TLS_LOCAL_VER=$(/usr/local/bin/simple-tls -v 2>&1 | cut -d '-' -f 1)
SIMPLE_TLS_GIT_VER=$(curl -f -s $SIMPLE_TLS_URL/$SIMPLE_TLS_VER | jq -r '."tag_name"')
echo "$(date): Start checking for Simple TLS updates ..."
if [ ! -z "$SIMPLE_TLS_GIT_VER" ] && [ "$SIMPLE_TLS_LOCAL_VER" != "$SIMPLE_TLS_GIT_VER" ]; then
    echo "$(date): Updating Simple TLS to version $SIMPLE_TLS_GIT_VER ..."
    wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/simple_tls.zip --tries=3 $(\
    curl -s $SIMPLE_TLS_URL/$SIMPLE_TLS_VER | grep -o -E 'http.+\w+' | grep -i "$(uname)" | \
    grep -i -E "$(dpkg --print-architecture | sed "s/armhf/arm-7/g")")
    if [ $? -eq 0 ]; then
        unzip -x -o simple_tls.zip simple-tls -d /usr/local/bin
        chmod a+x /usr/local/bin/*
        SIMPLE_TLS_LOCAL_VER=$(/usr/local/bin/simple-tls -v 2>&1 | cut -d '-' -f 1)
        echo "$(date): Simple TLS updated to version $SIMPLE_TLS_LOCAL_VER"
        if [ "$SIMPLE_TLS_ENABLED" = "true" ]; then
            /etc/init.d/ss-simple-tls.sh restart
            sleep 3
            /etc/init.d/ss-simple-tls.sh status
        fi
    else
        echo "$(date): Update Simple TLS failed. Check update source url: $SIMPLE_TLS_URL/$SIMPLE_TLS_VER"
    fi
else
    echo "$(date): Simple TLS version $SIMPLE_TLS_LOCAL_VER is latest. Nothing to update."
fi

# Update V2RAY
V2RAY_VER=$([ "$V2RAY_VER" != "latest" ] && echo tags/$V2RAY_VER || echo $V2RAY_VER)
V2RAY_LOCAL_VER=$(/usr/local/bin/v2ray --version | grep v2ray | cut -d ' ' -f 2)
V2RAY_GIT_VER=$(curl -f -s $V2RAY_URL/$V2RAY_VER | jq -r '."tag_name"')
echo "$(date): Start checking for V2RAY updates ..."
if [ ! -z "$V2RAY_GIT_VER" ] && [ "$V2RAY_LOCAL_VER" != "$V2RAY_GIT_VER" ]; then
    echo "$(date): Updating V2RAY to version $V2RAY_GIT_VER ..."
    wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/v2ray.tar.gz --tries=3 $(\
    curl -s $V2RAY_URL/$V2RAY_VER | grep -o -E 'http.+\w+' | grep -i "$(uname)" | \
    grep -i -E "$(dpkg --print-architecture | sed "s/armhf/-arm-/g")")
    if [ $? -eq 0 ]; then
        tar --directory /usr/local/bin -xf v2ray.tar.gz $(tar -tf v2ray.tar.gz | grep -i -E "$(dpkg --print-architecture | sed "s/armhf/_arm7/g")") && ln -s -f /usr/local/bin/v2ray-* /usr/local/bin/v2ray
        chmod a+x /usr/local/bin/*
        V2RAY_LOCAL_VER=$(/usr/local/bin/v2ray --version | grep v2ray | cut -d ' ' -f 2)
        echo "$(date): V2RAY updated to version $V2RAY_LOCAL_VER"
        if [ "$V2RAY_ENABLED" = "true" ]; then
            /etc/init.d/ss-v2ray.sh restart
            sleep 3
            /etc/init.d/ss-v2ray.sh status
        fi
    else
        echo "$(date): Update V2RAY failed. Check update source url: $V2RAY_URL/$V2RAY_VER"
    fi
else
    echo "$(date): V2RAY version $V2RAY_LOCAL_VER is latest. Nothing to update."
fi

cd / && rm -rf /tmp/ss

echo " "
echo "=================================================="
echo "$(date): update.sh finished"
echo "=================================================="
echo " "
