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

# 3. Substituir variáveis nos templates de configuração PJSIP e Dialplan
sed -i "s|\${PUBLIC_IP}|${PUBLIC_IP}|g" /etc/asterisk/pjsip.conf
sed -i "s|\${TRUNK_HOST}|${TRUNK_HOST}|g" /etc/asterisk/pjsip.conf
sed -i "s|\${TRUNK_PORT}|${TRUNK_PORT}|g" /etc/asterisk/pjsip.conf
sed -i "s|\${TRUNK_USER}|${TRUNK_USER}|g" /etc/asterisk/pjsip.conf
sed -i "s|\${TRUNK_PASSWORD}|${TRUNK_PASSWORD}|g" /etc/asterisk/pjsip.conf
sed -i "s|\${WEBRTC_EXT_USER}|${WEBRTC_EXT_USER}|g" /etc/asterisk/pjsip.conf
sed -i "s|\${WEBRTC_EXT_PASS}|${WEBRTC_EXT_PASS}|g" /etc/asterisk/pjsip.conf

sed -i "s|\${TRUNK_USER}|${TRUNK_USER}|g" /etc/asterisk/extensions.conf

echo "[Asterisk] Configurações aplicadas com sucesso. Iniciando Asterisk..."

exec "$@"
