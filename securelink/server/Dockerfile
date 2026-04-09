FROM alpine:3.18

RUN apk add --no-cache openvpn bash iproute2

WORKDIR /etc/openvpn

COPY server.conf /etc/openvpn/server.conf
COPY scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 1194/udp

ENTRYPOINT ["/entrypoint.sh"]
