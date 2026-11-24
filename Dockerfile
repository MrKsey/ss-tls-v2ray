#
# Shadowsocks-rust + v2ray (websocket-http) + simple-tls (TLS1.3)
#

FROM ubuntu:latest

ENV OWNER="MrKsey"
ENV REPO="ss-tls-v2ray"

ENV GIT_URL="https://github.com/$OWNER/$REPO"
ENV SS_URL="https://api.github.com/repos/shadowsocks/shadowsocks-rust/releases"
ENV SS_VER="latest"
ENV SIMPLE_TLS_URL="https://api.github.com/repos/MrKsey/simple-tls/releases"
ENV SIMPLE_TLS_VER="latest"
ENV V2RAY_URL="https://api.github.com/repos/shadowsocks/v2ray-plugin/releases"
ENV V2RAY_VER="latest"
ENV CLOACK_URL="https://api.github.com/repos/MrKsey/Cloak/releases"
ENV CLOACK_VER="latest"
ENV USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:77.0) Gecko/20100101 Firefox/77.0"
ENV CONFIG_PATH="/etc/shadowsocks"

COPY start.sh /start.sh
COPY config.sh /config.sh
COPY update.sh /update.sh
COPY ps_exit.sh /ps_exit.sh
COPY restart_svc.sh /restart_svc.sh

RUN export DEBIAN_FRONTEND=noninteractive \
&& chmod a+x /start.sh /config.sh /update.sh /ps_exit.sh /restart_svc.sh \
&& apt-get update \
&& apt-get install --no-install-recommends -y ca-certificates tzdata curl wget xz-utils unzip jq moreutils libcap2-bin cron net-tools dos2unix entr git \
&& dos2unix /start.sh /config.sh /update.sh /ps_exit.sh /restart_svc.sh \
&& mkdir -p /tmp/ss && cd /tmp/ss \
&& ARCH=$(dpkg --print-architecture) \
\
# 1. Shadowsocks-rust
&& export SS_VER=$([ "$SS_VER" != "latest" ] && echo "tags/$SS_VER" || echo "$SS_VER") \
&& SS_DL=$(curl -fsSL "$SS_URL/$SS_VER" | jq -r '.assets[].browser_download_url' | grep -i "$(uname)" | grep -i "gnu" | grep -v "sha256" | grep -i -E "$(echo $ARCH | sed 's/amd64/x86_64/g; s/arm64/aarch64/g; s/armhf/arm.+eabihf/g')") \
&& wget --no-verbose --user-agent="$USER_AGENT" --output-document=/tmp/ss/ss.tar.xz --tries=3 "$SS_DL" \
&& tar -xf ss.tar.xz --directory /usr/local/bin \
\
# 2. Simple-TLS
&& export SIMPLE_TLS_VER=$([ "$SIMPLE_TLS_VER" != "latest" ] && echo "tags/$SIMPLE_TLS_VER" || echo "$SIMPLE_TLS_VER") \
&& TLS_DL=$(curl -fsSL "$SIMPLE_TLS_URL/$SIMPLE_TLS_VER" | jq -r '.assets[].browser_download_url' | grep -i "$(uname)" | grep -i -E "$(echo $ARCH | sed 's/armhf/arm-7/g')") \
&& wget --no-verbose --user-agent="$USER_AGENT" --output-document=/tmp/ss/simple_tls.zip --tries=3 "$TLS_DL" \
&& unzip -x -o simple_tls.zip simple-tls -d /usr/local/bin \
\
# 3. V2ray-plugin
&& export V2RAY_VER=$([ "$V2RAY_VER" != "latest" ] && echo "tags/$V2RAY_VER" || echo "$V2RAY_VER") \
&& V2RAY_DL=$(curl -fsSL "$V2RAY_URL/$V2RAY_VER" | jq -r '.assets[].browser_download_url' | grep -i "$(uname)" | grep -i -E "$(echo $ARCH | sed 's/armhf/arm-v/g')") \
&& wget --no-verbose --user-agent="$USER_AGENT" --output-document=/tmp/ss/v2ray.tar.gz --tries=3 "$V2RAY_DL" \
&& tar --directory /usr/local/bin -xf v2ray.tar.gz $(tar -tf v2ray.tar.gz | grep -i -E "$(echo $ARCH | sed 's/armhf/_arm7/g')") \
&& ln -f -s /usr/local/bin/v2ray-* /usr/local/bin/v2ray \
\
# 4. Cloak
&& export CLOACK_VER=$([ "$CLOACK_VER" != "latest" ] && echo "tags/$CLOACK_VER" || echo "$CLOACK_VER") \
&& CLOAK_JSON=$(curl -fsSL "$CLOACK_URL/$CLOACK_VER") \
&& CLOAK_SRV_DL=$(echo "$CLOAK_JSON" | jq -r '.assets[].browser_download_url' | grep -i "$(uname)" | grep server | grep -i -E "$(echo $ARCH | sed 's/armhf/-arm-/g')") \
&& CLOAK_CLI_DL=$(echo "$CLOAK_JSON" | jq -r '.assets[].browser_download_url' | grep -i "$(uname)" | grep client | grep -i -E "$(echo $ARCH | sed 's/armhf/-arm-/g')") \
&& wget --no-verbose --user-agent="$USER_AGENT" --output-document=/usr/local/bin/cloack-server --tries=3 "$CLOAK_SRV_DL" \
&& wget --no-verbose --user-agent="$USER_AGENT" --output-document=/tmp/ss/cloack-client --tries=3 "$CLOAK_CLI_DL" \
&& cp /tmp/ss/cloack-client /usr/local/bin/ \
\
&& chown -R root:root /usr/local/bin && chmod -R a+x /usr/local/bin \
&& cd / && rm -rf /tmp/ss \
&& apt-get purge -y -q --auto-remove \
&& apt-get clean \
&& touch /var/log/cron.log \
&& ln -sf /proc/1/fd/1 /var/log/cron.log

VOLUME [ "$CONFIG_PATH" ]


ENTRYPOINT ["/start.sh"]
