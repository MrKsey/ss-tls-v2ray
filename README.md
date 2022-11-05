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
- automatic client configuration (simply put _CLIENT.txt from server to client folder /ss and start container).

### Default mode - server

### Server default ports:
shadowsocks-rust: 8443, simple-tls: 443, v2ray: 80

### Cleint default ports:
shadowsocks-rust: 1843, simple-tls: 1443, v2ray: 1080

More info:
- https://github.com/shadowsocks/shadowsocks-rust
- https://github.com/IrineSistiana/simple-tls
- https://github.com/shadowsocks/v2ray-plugin

### How to install:
- сreate "/docker/ss" directory (for example) on your host
- connect host directory "/docker/ss" to the container directory "/etc/shadowsocks" and start container:
```
docker run --name ss-tls-v2ray -d --restart=unless-stopped --net=host -v /docker/ss:/etc/shadowsocks ksey/ss-tls-v2ray
```

### View shadowsocks server links and QR-codes:
To view QR-codes install python3-qrcode:
```
sudo apt install python3-qrcode
export PYTHONIOENCODING=utf8
```
- Shadowsocks link and qr-code:
```
cat /docker/ss/_CLIENT.txt | grep SS_LINK | grep -E -o "ss://.+"
cat /docker/ss/_CLIENT.txt | grep SS_LINK | grep -E -o "ss://.+" | qr
```

- Simple-tls link and qr-code:
```
cat /docker/ss/_CLIENT.txt | grep SIMPLE_TLS_LINK | grep -E -o "ss://.+"
cat /docker/ss/_CLIENT.txt | grep SIMPLE_TLS_LINK | grep -E -o "ss://.+" | qr
```

- V2ray link and qr-code:
```
cat /docker/ss/_CLIENT.txt | grep V2RAY_LINK | grep -E -o "ss://.+"
cat /docker/ss/_CLIENT.txt | grep V2RAY_LINK | grep -E -o "ss://.+" | qr
```

### Update image and container:

```
sudo docker stop ss-tls-v2ray
sudo docker rm ss-tls-v2ray
sudo docker image rm ksey/ss-tls-v2ray
sudo docker run --name ss-tls-v2ray -d --restart=unless-stopped --net=host -v /docker/ss:/etc/shadowsocks ksey/ss-tls-v2ray
```
