#
# Shadowsocks-rust + v2ray (websocket-http) + simple-tls (TLS1.3)
#

FROM ubuntu:latest

ENV GIT_URL="https://github.com/MrKsey/ss-tls-v2ray"
ENV SS_URL="https://api.github.com/repos/shadowsocks/shadowsocks-rust/releases"
ENV SS_VER="latest"
ENV SIMPLE_TLS_URL="https://api.github.com/repos/IrineSistiana/simple-tls/releases"
ENV SIMPLE_TLS_VER="latest"
ENV V2RAY_URL="https://api.github.com/repos/shadowsocks/v2ray-plugin/releases"
ENV V2RAY_VER="latest"
ENV USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:77.0) Gecko/20100101 Firefox/77.0"
ENV CONFIG_PATH="/etc/shadowsocks"

COPY start.sh /start.sh
COPY config.sh /config.sh
COPY update.sh /update.sh
COPY ps_exit.sh /ps_exit.sh

RUN export DEBIAN_FRONTEND=noninteractive \
&& chmod a+x /start.sh && chmod a+x /config.sh && chmod a+x /update.sh \
&& apt-get update && apt-get upgrade -y \
&& apt-get install --no-install-recommends -y ca-certificates tzdata curl wget xz-utils unzip jq subversion moreutils libcap2-bin cron lsof dos2unix \
&& dos2unix /start.sh && dos2unix /config.sh && dos2unix /update.sh && dos2unix /ps_exit.sh \
&& mkdir /tmp/ss && cd /tmp/ss \
&& export SS_VER=$([ "$SS_VER" != "latest" ] && echo tags/$SS_VER || echo $SS_VER) \
&& wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/ss.tar.xz --tries=3 $(\
   curl -s $SS_URL/$SS_VER | grep -o -E 'http.+\w+' | grep -i "$(uname)" | grep -i "gnu" | grep -i -v "sha256" | \
   grep -i -E "$(dpkg --print-architecture | sed "s/amd64/x86_64/g" | sed "s/arm64/aarch64/g" | sed -E "s/armhf/arm.+eabihf/g")") \
&& tar -xf ss.tar.xz --directory /usr/local/bin \
&& export SIMPLE_TLS_VER=$([ "$SIMPLE_TLS_VER" != "latest" ] && echo tags/$SIMPLE_TLS_VER || echo $SIMPLE_TLS_VER) \
&& wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/simple_tls.zip --tries=3 $(\
   curl -s $SIMPLE_TLS_URL/$SIMPLE_TLS_VER | grep -o -E 'http.+\w+' | grep -i "$(uname)" | \
   grep -i -E "$(dpkg --print-architecture | sed "s/armhf/arm-7/g")") \
&& unzip -x -o simple_tls.zip simple-tls -d /usr/local/bin \
&& export V2RAY_VER=$([ "$V2RAY_VER" != "latest" ] && echo tags/$V2RAY_VER || echo $V2RAY_VER) \
&& wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/v2ray.tar.gz --tries=3 $(\
   curl -s $V2RAY_URL/$V2RAY_VER | grep -o -E 'http.+\w+' | grep -i "$(uname)" | \
   grep -i -E "$(dpkg --print-architecture | sed "s/armhf/arm-v/g")") \
&& tar --directory /usr/local/bin -xf v2ray.tar.gz $(tar -tf v2ray.tar.gz | grep -i -E "$(dpkg --print-architecture | sed "s/armhf/_arm7/g")") && ln -f -s /usr/local/bin/v2ray-* /usr/local/bin/v2ray \
&& chown -R root:root /usr/local/bin && chmod -R a+x /usr/local/bin \
&& cd / && rm -rf /tmp/ss \
&& apt-get purge -y -q --auto-remove \
&& apt-get clean \
&& touch /var/log/cron.log \
&& ln -sf /proc/1/fd/1 /var/log/cron.log

VOLUME [ "$CONFIG_PATH" ]

ENTRYPOINT ["/start.sh"]
