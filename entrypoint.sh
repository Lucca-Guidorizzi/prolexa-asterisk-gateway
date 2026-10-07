#!/bin/bash
set -e

# ==============================================================================
# Asterisk Docker Entrypoint - Prolexa CRM
# Substitui variáveis de ambiente e garante certificados TLS/WSS para WebRTC
# ==============================================================================

# 1. Definir valores padrão para variáveis caso não fornecidas
export PUBLIC_IP=${PUBLIC_IP:-"127.0.0.1"}
export TRUNK_HOST=${TRUNK_HOST:-"189.3.77.93"}
export TRUNK_PORT=${TRUNK_PORT:-"5060"}
export TRUNK_USER=${TRUNK_USER:-"1000"}
export TRUNK_PASSWORD=${TRUNK_PASSWORD:-"secret"}
export WEBRTC_EXT_USER=${WEBRTC_EXT_USER:-"1001"}
export WEBRTC_EXT_PASS=${WEBRTC_EXT_PASS:-"ProlexaSecret1001@"}

echo "[Asterisk] Inicializando PABX WebRTC Gateway..."
echo "[Asterisk] IP Público configurado: ${PUBLIC_IP}"
echo "[Asterisk] Tronco SIP da Operadora: ${TRUNK_USER}@${TRUNK_HOST}:${TRUNK_PORT}"

# 2. Gerar certificado autoassinado para WSS caso não existam chaves montadas
mkdir -p /etc/asterisk/keys
if [ ! -f /etc/asterisk/keys/asterisk.crt ] || [ ! -f /etc/asterisk/keys/asterisk.key ]; then
    echo "[Asterisk] Gerando certificado SSL autoassinado para WebSockets (WSS)..."
    openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
        -subj "/C=BR/ST=SP/L=SaoPaulo/O=Prolexa/CN=${PUBLIC_IP}" \
        -keyout /etc/asterisk/keys/asterisk.key \
        -out /etc/asterisk/keys/asterisk.crt 2>/dev/null
    chmod 600 /etc/asterisk/keys/asterisk.key
fi

python3 -c "
import os
for path in ['/etc/asterisk/pjsip.conf', '/etc/asterisk/extensions.conf']:
    if os.path.exists(path):
        with open(path, 'r') as f:
            c = f.read()
        for k in ['PUBLIC_IP', 'TRUNK_HOST', 'TRUNK_PORT', 'TRUNK_USER', 'TRUNK_PASSWORD', 'WEBRTC_EXT_USER', 'WEBRTC_EXT_PASS']:
            val = os.environ.get(k, '')
            c = c.replace('\${' + k + '}', val)
        with open(path, 'w') as f:
            f.write(c)
" 2>/dev/null || node -e "
const fs = require('fs');
['/etc/asterisk/pjsip.conf', '/etc/asterisk/extensions.conf'].forEach(p => {
    if (fs.existsSync(p)) {
        let c = fs.readFileSync(p, 'utf8');
        ['PUBLIC_IP', 'TRUNK_HOST', 'TRUNK_PORT', 'TRUNK_USER', 'TRUNK_PASSWORD', 'WEBRTC_EXT_USER', 'WEBRTC_EXT_PASS'].forEach(k => {
            c = c.split('\${' + k + '}').join(process.env[k] || '');
        });
        fs.writeFileSync(p, c, 'utf8');
    }
});
" 2>/dev/null || {
    # Fallback caso python/node não estejam instalados: sed com delimitador seguro
    sed -i "s|\${PUBLIC_IP}|${PUBLIC_IP}|g" /etc/asterisk/pjsip.conf
    sed -i "s|\${TRUNK_HOST}|${TRUNK_HOST}|g" /etc/asterisk/pjsip.conf
    sed -i "s|\${TRUNK_PORT}|${TRUNK_PORT}|g" /etc/asterisk/pjsip.conf
    sed -i "s|\${TRUNK_USER}|${TRUNK_USER}|g" /etc/asterisk/pjsip.conf
    sed -i "s|\${TRUNK_PASSWORD}|$(echo "$TRUNK_PASSWORD" | sed -e 's/[\/&]/\\&/g')|g" /etc/asterisk/pjsip.conf
    sed -i "s|\${WEBRTC_EXT_USER}|${WEBRTC_EXT_USER}|g" /etc/asterisk/pjsip.conf
    sed -i "s|\${WEBRTC_EXT_PASS}|$(echo "$WEBRTC_EXT_PASS" | sed -e 's/[\/&]/\\&/g')|g" /etc/asterisk/pjsip.conf
    sed -i "s|\${TRUNK_USER}|${TRUNK_USER}|g" /etc/asterisk/extensions.conf
}

echo "[Asterisk] Configurações aplicadas com sucesso. Iniciando Asterisk..."

exec "$@"
