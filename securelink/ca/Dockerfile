FROM alpine:3.18

RUN apk add --no-cache openssl bash

WORKDIR /ca

COPY openssl.cnf /ca/openssl.cnf
COPY scripts/ /ca/scripts/

RUN chmod +x /ca/scripts/*.sh

CMD ["bash"]
