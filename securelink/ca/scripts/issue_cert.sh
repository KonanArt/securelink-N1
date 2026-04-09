#!/bin/bash
# =============================================================
# issue_cert.sh — Emite certificado para um nó específico
# =============================================================
# Uso: ./issue_cert.sh <nome-do-no>
# Exemplo: ./issue_cert.sh server
#          ./issue_cert.sh client
# =============================================================

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Uso: $0 <nome-do-no>"
    exit 1
fi

NODE_NAME="$1"
CA_DIR="/ca/data"
CONF="/ca/openssl.cnf"

COUNTRY="BR"
STATE="Sao Paulo"
ORG="SecureLink CA"
CN="$NODE_NAME.securelink.internal"

log() { echo "[CA] $*"; }

NODE_KEY="$CA_DIR/private/$NODE_NAME.key.pem"
NODE_CSR="$CA_DIR/$NODE_NAME.csr.pem"
NODE_CERT="$CA_DIR/certs/$NODE_NAME.cert.pem"

# ------------------------------------------------------------------
# 1. Gerar chave privada do nó
# ------------------------------------------------------------------
if [ ! -f "$NODE_KEY" ]; then
    log "Gerando chave privada para '$NODE_NAME'..."
    openssl genrsa -out "$NODE_KEY" 2048
    chmod 400 "$NODE_KEY"
else
    log "Chave '$NODE_NAME' já existe, pulando."
fi

# ------------------------------------------------------------------
# 2. Gerar CSR (Certificate Signing Request)
# ------------------------------------------------------------------
log "Gerando CSR para '$NODE_NAME'..."
openssl req -config "$CONF" \
    -key "$NODE_KEY" \
    -new -sha256 \
    -subj "/C=$COUNTRY/ST=$STATE/O=$ORG/CN=$CN" \
    -out "$NODE_CSR"

# ------------------------------------------------------------------
# 3. Assinar o CSR com a CA raiz
# ------------------------------------------------------------------
log "Assinando certificado para '$NODE_NAME' com a CA raiz..."

# Escolhe extensão adequada conforme o tipo de nó
if [ "$NODE_NAME" = "server" ]; then
    EXT="server_cert"
else
    EXT="usr_cert"
fi

openssl ca -config "$CONF" \
    -extensions "$EXT" \
    -days 375 -notext -md sha256 \
    -in "$NODE_CSR" \
    -out "$NODE_CERT" \
    -batch

chmod 444 "$NODE_CERT"

# ------------------------------------------------------------------
# 4. Verificar e exibir informações do certificado emitido
# ------------------------------------------------------------------
log "Verificando certificado emitido..."
openssl verify -CAfile "$CA_DIR/certs/ca.cert.pem" "$NODE_CERT"

log "Certificado emitido com sucesso: $NODE_CERT"
log "  Subject : $(openssl x509 -noout -subject -in "$NODE_CERT")"
log "  Validity: $(openssl x509 -noout -dates  -in "$NODE_CERT")"
