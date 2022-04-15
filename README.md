# ss-tls-v2ray
Server/client with shadowsocks-rust + v2ray (websocket-http) + simple-tls (TLS1.3)
Shadowsocks is a fast tunnel proxy that helps you bypass firewalls.
v2ray and simple-tls is obfuscation plugins for Shadowsocks. The purpose of this plugins is to change the characteristics of network traffic so that it is not identified and subsequently blocked by network filtering devices.

### Key futures:
- autoupdates
- flexible configuration with config.ini
- automatic generation password for Shadowsocks
- automatic generation certificate for simple-tls 
- 3 types independent tunnels: shadowsocks-rust, v2ray and simple-tls
- automatic client configuration (simply put CLIENT.txt from server to client folder /ss and start container).

### Default mode - server

### Server default ports:
shadowsocks-rust: 8443, simple-tls: 443, v2ray: 80

### Cleint default ports:
shadowsocks-rust: 1843, simple-tls: 1443, v2ray: 1080

More info:
- https://github.com/shadowsocks/shadowsocks-rust
- https://github.com/IrineSistiana/simple-tls
- https://github.com/shadowsocks/v2ray-plugin

### Installing
- сreate "/ss" directory (for example) on your host
- connect host directory "/ss" to the container directory "/etc/shadowsocks" and start container:
```
docker run --name ss-tls-v2ray -d --restart=unless-stopped --net=host -v /ss:/etc/shadowsocks ksey/ss-tls-v2ray
```
