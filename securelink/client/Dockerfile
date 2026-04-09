FROM alpine:3.18

RUN apk add --no-cache openvpn bash

WORKDIR /etc/openvpn

COPY client.conf /etc/openvpn/client.conf
COPY scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
