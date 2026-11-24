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
ARCH=$(dpkg --print-architecture)

# Update ShadowSocks
SS_VER=$([ "$SS_VER" != "latest" ] && echo "tags/$SS_VER" || echo "$SS_VER")
SS_LOCAL_VER=$(/usr/local/bin/ssserver --version | cut -d ' ' -f 2 | sed -E "s/^[a-zA-Z]//")
SS_JSON=$(curl -fsSL "$SS_URL/$SS_VER")
SS_GIT_VER=$(echo "$SS_JSON" | jq -r '.tag_name // empty' | sed -E "s/^[a-zA-Z]//")
echo "$(date): Start checking for ShadowSocks updates ..."
if [ -n "$SS_GIT_VER" ] && [ "$SS_LOCAL_VER" != "$SS_GIT_VER" ]; then
    echo "$(date): Updating ShadowSocks to version $SS_GIT_VER ..."
    SS_DL=$(echo "$SS_JSON" | jq -r '.assets[].browser_download_url' | grep -i "$(uname)" | grep -i "gnu" | grep -v "sha256" | grep -i -E "$(echo $ARCH | sed 's/amd64/x86_64/g; s/arm64/aarch64/g; s/armhf/arm.+eabihf/g')")
    if [ -n "$SS_DL" ] && wget --no-verbose --user-agent="$USER_AGENT" --output-document=/tmp/ss/ss.tar.xz --tries=3 "$SS_DL"; then
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
SIMPLE_TLS_VER=$([ "$SIMPLE_TLS_VER" != "latest" ] && echo "tags/$SIMPLE_TLS_VER" || echo "$SIMPLE_TLS_VER")
SIMPLE_TLS_LOCAL_VER=$(/usr/local/bin/simple-tls -v 2>&1 | cut -d '-' -f 1 | sed -E "s/^[a-zA-Z]//")
TLS_JSON=$(curl -fsSL "$SIMPLE_TLS_URL/$SIMPLE_TLS_VER")
SIMPLE_TLS_GIT_VER=$(echo "$TLS_JSON" | jq -r '.tag_name // empty' | sed -E "s/^[a-zA-Z]//")
echo "$(date): Start checking for Simple TLS updates ..."
if [ -n "$SIMPLE_TLS_GIT_VER" ] && [ "$SIMPLE_TLS_LOCAL_VER" != "$SIMPLE_TLS_GIT_VER" ]; then
    echo "$(date): Updating Simple TLS to version $SIMPLE_TLS_GIT_VER ..."
    TLS_DL=$(echo "$TLS_JSON" | jq -r '.assets[].browser_download_url' | grep -i "$(uname)" | grep -i -E "$(echo $ARCH | sed 's/armhf/arm-7/g')")
    if [ -n "$TLS_DL" ] && wget --no-verbose --user-agent="$USER_AGENT" --output-document=/tmp/ss/simple_tls.zip --tries=3 "$TLS_DL"; then
        mkdir -p /tmp/ss/tls_ext && unzip -o simple_tls.zip -d /tmp/ss/tls_ext
        mv /tmp/ss/tls_ext/simple-tls* /usr/local/bin/simple-tls
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
V2RAY_VER=$([ "$V2RAY_VER" != "latest" ] && echo "tags/$V2RAY_VER" || echo "$V2RAY_VER")
V2RAY_LOCAL_VER=$(/usr/local/bin/v2ray --version | grep v2ray | cut -d ' ' -f 2 | sed -E "s/^[a-zA-Z]//")
V2RAY_JSON=$(curl -fsSL "$V2RAY_URL/$V2RAY_VER")
V2RAY_GIT_VER=$(echo "$V2RAY_JSON" | jq -r '.tag_name // empty' | sed -E "s/^[a-zA-Z]//")
echo "$(date): Start checking for V2RAY updates ..."
if [ -n "$V2RAY_GIT_VER" ] && [ "$V2RAY_LOCAL_VER" != "$V2RAY_GIT_VER" ]; then
    echo "$(date): Updating V2RAY to version $V2RAY_GIT_VER ..."
    V2RAY_DL=$(echo "$V2RAY_JSON" | jq -r '.assets[].browser_download_url' | grep -i "$(uname)" | grep -i -E "$(echo $ARCH | sed 's/armhf/arm-v/g')")
    if [ -n "$V2RAY_DL" ] && wget --no-verbose --user-agent="$USER_AGENT" --output-document=/tmp/ss/v2ray.tar.gz --tries=3 "$V2RAY_DL"; then
        tar --directory /usr/local/bin -xf v2ray.tar.gz $(tar -tf v2ray.tar.gz | grep -i -E "$(echo $ARCH | sed 's/armhf/_arm7/g')") && ln -s -f /usr/local/bin/v2ray-* /usr/local/bin/v2ray
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

# Update CLOACK
if [ "$MODE" == "server" ]; then
    CLOACK_ENDING="server"
else
    CLOACK_ENDING="client"
fi
CLOACK_VER=$([ "$CLOACK_VER" != "latest" ] && echo "tags/$CLOACK_VER" || echo "$CLOACK_VER")
CLOACK_LOCAL_VER=$(/usr/local/bin/cloack-$CLOACK_ENDING -v | grep -E -o "v[0-9.]+")
CLOAK_JSON=$(curl -fsSL "$CLOACK_URL/$CLOACK_VER")
CLOACK_GIT_VER=$(echo "$CLOAK_JSON" | jq -r '.tag_name // empty')
echo "$(date): Start checking for CLOACK updates ..."
if [ -n "$CLOACK_GIT_VER" ] && [ "$CLOACK_LOCAL_VER" != "$CLOACK_GIT_VER" ]; then
    echo "$(date): Updating CLOACK to version $CLOACK_GIT_VER ..."
    CLOAK_DL=$(echo "$CLOAK_JSON" | jq -r '.assets[].browser_download_url' | grep -i "$(uname)" | grep "$CLOACK_ENDING" | grep -i -E "$(echo $ARCH | sed 's/armhf/-arm-/g')")
    if [ -n "$CLOAK_DL" ] && wget --no-verbose --user-agent="$USER_AGENT" --output-document=/tmp/ss/cloack-$CLOACK_ENDING --tries=3 "$CLOAK_DL"; then
        cp ./cloack-$CLOACK_ENDING /usr/local/bin/
        chmod a+x /usr/local/bin/*
        CLOACK_LOCAL_VER=$(/usr/local/bin/cloack-$CLOACK_ENDING -v | grep -E -o "v[0-9.]+")
        echo "$(date): CLOACK updated to version $CLOACK_LOCAL_VER"
        if [ "$CLOACK_ENABLED" = "true" ]; then
            /etc/init.d/cloack_$CLOACK_ENDING.sh restart
            sleep 3
            /etc/init.d/cloack_$CLOACK_ENDING.sh status
        fi
    else
        echo "$(date): Update CLOACK failed. Check update source url: $CLOACK_URL/$CLOACK_VER"
    fi
else
    echo "$(date): CLOACK version $CLOACK_LOCAL_VER is latest. Nothing to update."
fi

cd / && rm -rf /tmp/ss

echo " "
echo "=================================================="
echo "$(date): update.sh finished"
echo "=================================================="
echo " "
