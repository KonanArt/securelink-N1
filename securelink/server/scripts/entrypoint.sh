#!/bin/bash
# =============================================================
# entrypoint.sh — Inicialização do servidor OpenVPN
# =============================================================

set -euo pipefail

log() { echo "[SERVER] $*"; }

# ------------------------------------------------------------------
# 1. Aguardar certificados gerados pela CA
# ------------------------------------------------------------------
REQUIRED_FILES=(
    /certs/ca.cert.pem
    /certs/server.cert.pem
    /certs/server.key.pem
    /certs/dh.pem
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
# 2. Habilitar IP forwarding
# ------------------------------------------------------------------
log "Habilitando IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward

# ------------------------------------------------------------------
# 3. Criar diretório de logs
# ------------------------------------------------------------------
mkdir -p /var/log/openvpn

# ------------------------------------------------------------------
# 4. Iniciar servidor OpenVPN
# ------------------------------------------------------------------
log "Iniciando servidor OpenVPN..."
exec openvpn --config /etc/openvpn/server.conf
