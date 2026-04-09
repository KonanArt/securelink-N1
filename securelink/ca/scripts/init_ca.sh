#!/bin/bash
# =============================================================
# init_ca.sh — Inicializa a CA raiz e emite todos os certificados
# =============================================================
# Uso: ./init_ca.sh
# =============================================================

set -euo pipefail

CA_DIR="/ca/data"
CONF="/ca/openssl.cnf"

COUNTRY="BR"
STATE="Sao Paulo"
ORG="SecureLink CA"
CN_CA="SecureLink Root CA"

log() { echo "[CA] $*"; }

# ------------------------------------------------------------------
# 1. Preparar estrutura de diretórios da CA
# ------------------------------------------------------------------
log "Criando estrutura de diretórios..."
mkdir -p "$CA_DIR"/{certs,crl,newcerts,private}
chmod 700 "$CA_DIR/private"

[ -f "$CA_DIR/index.txt" ] || touch "$CA_DIR/index.txt"
[ -f "$CA_DIR/serial" ]    || echo 1000 > "$CA_DIR/serial"
[ -f "$CA_DIR/crlnumber" ] || echo 1000 > "$CA_DIR/crlnumber"

# ------------------------------------------------------------------
# 2. Gerar chave privada da CA raiz (4096 bits)
# ------------------------------------------------------------------
if [ ! -f "$CA_DIR/private/ca.key.pem" ]; then
    log "Gerando chave privada da CA raiz..."
    openssl genrsa -out "$CA_DIR/private/ca.key.pem" 4096
    chmod 400 "$CA_DIR/private/ca.key.pem"
else
    log "Chave da CA já existe, pulando geração."
fi

# ------------------------------------------------------------------
# 3. Gerar certificado auto-assinado da CA raiz
# ------------------------------------------------------------------
if [ ! -f "$CA_DIR/certs/ca.cert.pem" ]; then
    log "Gerando certificado auto-assinado da CA raiz..."
    openssl req -config "$CONF" \
        -key "$CA_DIR/private/ca.key.pem" \
        -new -x509 -days 3650 -sha256 \
        -extensions v3_ca \
        -subj "/C=$COUNTRY/ST=$STATE/O=$ORG/CN=$CN_CA" \
        -out "$CA_DIR/certs/ca.cert.pem"
    chmod 444 "$CA_DIR/certs/ca.cert.pem"
    log "CA raiz criada: $CA_DIR/certs/ca.cert.pem"
else
    log "Certificado da CA já existe, pulando geração."
fi

# ------------------------------------------------------------------
# 4. Emitir certificados para server e client
# ------------------------------------------------------------------
log "Emitindo certificado para o servidor..."
/ca/scripts/issue_cert.sh server

log "Emitindo certificado para o cliente..."
/ca/scripts/issue_cert.sh client

log "Inicialização da CA concluída com sucesso."
