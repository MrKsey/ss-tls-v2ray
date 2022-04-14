#!/bin/sh

if [ -s $CONFIG_PATH/.config.env ]; then
    set -a; . $CONFIG_PATH/.config.env; set +a
fi

# Update OS
if [ "$OS_UPDATE" = "true" ]; then
    apt-get update && apt-get upgrade -y && apt-get purge -y -q --auto-remove
fi

mkdir -p /tmp/ss && cd /tmp/ss

# Update ShadowSocks
SS_VER=$([ "$SS_VER" != "latest" ] && echo tags/$SS_VER || echo $SS_VER)
SS_LOCAL_VER=$(ssserver --version | cut -d ' ' -f 2)
SS_GIT_VER=$(curl -f -s $SS_URL/$SS_VER | jq -r '."tag_name"' | sed -E "s/^[a-zA-Z]//")
if [ ! -z "$SS_GIT_VER" ] && [ "$SS_LOCAL_VER" != "$SS_GIT_VER" ]; then
    wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/ss.tar.xz --tries=3 $(\
    curl -s $SS_URL/$SS_VER | grep -o -E 'http.+\w+' | grep -i "$(uname)" | grep -i "gnu" | grep -i -v "sha256" | \
    grep -i -E "$(dpkg --print-architecture | sed "s/amd64/x86_64/g" | sed "s/arm64/aarch64/g" | sed "s/armhf/arm.+eabihf/g")")
    if [ $? -eq 0 ]; then
        tar -xf ss.tar.xz --directory /usr/local/bin
        if [ "$SS_ENABLED" = "true" ]; then
            /etc/init.d/ss.sh restart
        else
            [ "$MODE" = "server" ] && /etc/init.d/ss.sh restart
        fi
    fi
fi

# Update Simple TLS
SIMPLE_TLS_VER=$([ "$SIMPLE_TLS_VER" != "latest" ] && echo tags/$SIMPLE_TLS_VER || echo $SIMPLE_TLS_VER)
SIMPLE_TLS_LOCAL_VER=$(simple-tls -v 2>&1 | cut -d '-' -f 1)
SIMPLE_TLS_GIT_VER=$(curl -f -s $SIMPLE_TLS_URL/$SIMPLE_TLS_VER | jq -r '."tag_name"')
if [ ! -z "$SIMPLE_TLS_GIT_VER" ] && [ "$SIMPLE_TLS_LOCAL_VER" != "$SIMPLE_TLS_GIT_VER" ]; then
    wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/simple_tls.zip --tries=3 $(\
    curl -s $SIMPLE_TLS_URL/$SIMPLE_TLS_VER | grep -o -E 'http.+\w+' | grep -i "$(uname)" | \
    grep -i -E "$(dpkg --print-architecture | sed "s/armhf/arm-7/g")")
    if [ $? -eq 0 ]; then
        unzip -x -o simple_tls.zip simple-tls -d /usr/local/bin
        if [ "$SIMPLE_TLS_ENABLED" = "true" ]; then
            /etc/init.d/ss-simple-tls.sh restart
        fi
    fi
fi

# Update V2RAY
V2RAY_VER=$([ "$V2RAY_VER" != "latest" ] && echo tags/$V2RAY_VER || echo $V2RAY_VER)
V2RAY_LOCAL_VER=$(v2ray --version | grep v2ray | cut -d ' ' -f 2)
V2RAY_GIT_VER=$(curl -f -s $V2RAY_URL/$V2RAY_VER | jq -r '."tag_name"')
if [ ! -z "$V2RAY_GIT_VER" ] && [ "$V2RAY_LOCAL_VER" != "$V2RAY_GIT_VER" ]; then
    wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/v2ray.tar.gz --tries=3 $(\
    curl -s $V2RAY_URL/$V2RAY_VER | grep -o -E 'http.+\w+' | grep -i "$(uname)" | \
    grep -i -E "$(dpkg --print-architecture | sed "s/armhf/-arm-/g")")
    if [ $? -eq 0 ]; then
        tar -xf v2ray.tar.gz --directory /usr/local/bin && ln -s -f /usr/local/bin/v2ray-* /usr/local/bin/v2ray
        if [ "$V2RAY_ENABLED" = "true" ]; then
            /etc/init.d/ss-v2ray.sh restart
        fi
    fi
fi

cd / && rm -rf /tmp/ss
