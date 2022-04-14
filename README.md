# ss-tls-v2ray-server
Server with shadowsocks-rust + v2ray (websocket-http) + simple-tls (TLS1.3)

### Installing
- сreate "/ss" directory (for example) on your host
- connect host directory "/ss" to the container directory "/etc/shadowsocks" and start container:
```
docker run --name ss-tls-v2ray -d --restart=unless-stopped --net=host -v /ss:/etc/shadowsocks ksey/ss-tls-v2ray
```
