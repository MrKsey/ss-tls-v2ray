#
# Shadowsocks-rust + v2ray (websocket-http) + simple-tls (TLS1.3) + cloack
#

FROM ubuntu:latest

ENV OWNER="MrKsey"
ENV REPO="ss-tls-v2ray"

ENV GIT_URL="https://github.com/$OWNER/$REPO"
ENV SS_URL="https://api.github.com/repos/shadowsocks/shadowsocks-rust/releases"
ENV SS_VER="latest"
ENV SIMPLE_TLS_URL="https://api.github.com/repos/IrineSistiana/simple-tls/releases"
ENV SIMPLE_TLS_VER="latest"
ENV V2RAY_URL="https://api.github.com/repos/shadowsocks/v2ray-plugin/releases"
ENV V2RAY_VER="latest"
ENV CLOACK_URL="https://api.github.com/repos/cbeuw/Cloak/releases"
ENV CLOACK_VER="latest"
ENV USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:77.0) Gecko/20100101 Firefox/77.0"
ENV CONFIG_PATH="/etc/shadowsocks"

COPY start.sh /start.sh
COPY config.sh /config.sh
COPY update.sh /update.sh
COPY ps_exit.sh /ps_exit.sh
COPY restart_svc.sh /restart_svc.sh

RUN export DEBIAN_FRONTEND=noninteractive \
&& chmod a+x /start.sh && chmod a+x /config.sh && chmod a+x /update.sh && chmod a+x /ps_exit.sh && chmod a+x /restart_svc.sh \
&& apt-get update \
&& apt-get install --no-install-recommends -y ca-certificates tzdata curl wget xz-utils unzip jq moreutils libcap2-bin cron net-tools dos2unix entr git \
&& dos2unix /start.sh && dos2unix /config.sh && dos2unix /update.sh && dos2unix /ps_exit.sh && dos2unix /restart_svc.sh \
&& mkdir /tmp/ss && cd /tmp/ss \
&& export ARCH=$(dpkg --print-architecture) \
&& export SS_VER=$([ "$SS_VER" != "latest" ] && echo tags/$SS_VER || echo $SS_VER) \
&& export SS_ASSET=$(curl -s $SS_URL/$SS_VER | jq -r '.assets[] | select(.name | test("x86_64|aarch64|armv7"; "i")) | select(.name | test("sha256"; "i") | not) | .browser_download_url' | head -1) \
&& wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/ss.tar.xz --tries=3 $SS_ASSET \
&& tar -xf ss.tar.xz --directory /usr/local/bin \
&& export SIMPLE_TLS_VER=$([ "$SIMPLE_TLS_VER" != "latest" ] && echo tags/$SIMPLE_TLS_VER || echo $SIMPLE_TLS_VER) \
&& export SIMPLE_ASSET=$(curl -s $SIMPLE_TLS_URL/$SIMPLE_TLS_VER | jq -r '.assets[] | select(.name | test("linux"; "i")) | select(.name | test("'"$ARCH"'"; "i")) | .browser_download_url' | head -1) \
&& wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/simple_tls.zip --tries=3 $SIMPLE_ASSET \
&& unzip -x -o simple_tls.zip simple-tls -d /usr/local/bin \
&& export V2RAY_VER=$([ "$V2RAY_VER" != "latest" ] && echo tags/$V2RAY_VER || echo $V2RAY_VER) \
&& export V2RAY_ASSET=$(curl -s $V2RAY_URL/$V2RAY_VER | jq -r '.assets[] | select(.name | test("linux"; "i")) | select(.name | test("'"$ARCH"'"; "i")) | .browser_download_url' | head -1) \
&& wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/v2ray.tar.gz --tries=3 $V2RAY_ASSET \
&& tar --directory /usr/local/bin -xf v2ray.tar.gz && ln -f -s /usr/local/bin/v2ray-* /usr/local/bin/v2ray \
&& export CLOACK_VER=$([ "$CLOACK_VER" != "latest" ] && echo tags/$CLOACK_VER || echo $CLOACK_VER) \
&& export CK_SERVER_ASSET=$(curl -s $CLOACK_URL/$CLOACK_VER | jq -r '.assets[] | select(.name | test("server"; "i")) | select(.name | test("'"$ARCH"'"; "i")) | .browser_download_url' | head -1) \
&& wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/cloack-server --tries=3 $CK_SERVER_ASSET \
&& cp /tmp/ss/cloack-server /usr/local/bin/ \
&& export CK_CLIENT_ASSET=$(curl -s $CLOACK_URL/$CLOACK_VER | jq -r '.assets[] | select(.name | test("client"; "i")) | select(.name | test("'"$ARCH"'"; "i")) | .browser_download_url' | head -1) \
&& wget --no-verbose --no-check-certificate --user-agent="$USER_AGENT" --output-document=/tmp/ss/cloack-client --tries=3 $CK_CLIENT_ASSET \
&& cp /tmp/ss/cloack-client /usr/local/bin/ \
&& chown -R root:root /usr/local/bin && chmod -R a+x /usr/local/bin \
&& cd / && rm -rf /tmp/ss \
&& apt-get purge -y -q --auto-remove \
&& apt-get clean \
&& touch /var/log/cron.log \
&& ln -sf /proc/1/fd/1 /var/log/cron.log

VOLUME [ "$CONFIG_PATH" ]

ENTRYPOINT ["/start.sh"]
