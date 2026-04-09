#!/bin/bash
# =============================================================
# entrypoint.sh — Inicialização do cliente OpenVPN
# =============================================================

set -euo pipefail

log() { echo "[CLIENT] $*"; }

# ------------------------------------------------------------------
# 1. Verificar variável de ambiente obrigatória
# ------------------------------------------------------------------
if [ -z "${SERVER_HOST:-}" ]; then
    log "ERRO: variável SERVER_HOST não definida."
    log "Defina SERVER_HOST no docker-compose.yml ou via -e SERVER_HOST=<ip>"
    exit 1
fi
log "Conectando ao servidor: $SERVER_HOST"

# ------------------------------------------------------------------
# 2. Verificar certificados
# ------------------------------------------------------------------
REQUIRED_FILES=(
    /certs/ca.cert.pem
    /certs/client.cert.pem
    /certs/client.key.pem
    /certs/ta.key
)

log "Verificando certificados..."
for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        log "ERRO: Arquivo ausente: $f"
        log "Execute o serviço 'ca' primeiro com: docker compose run ca /ca/scripts/init_ca.sh"
        exit 1
    fi
done
log "Todos os certificados encontrados."

# ------------------------------------------------------------------
# 3. Substituir SERVER_HOST na configuração e iniciar cliente
# ------------------------------------------------------------------
log "Aplicando configuração..."
envsubst < /etc/openvpn/client.conf > /tmp/client-resolved.conf

log "Iniciando cliente OpenVPN..."
exec openvpn --config /tmp/client-resolved.conf
