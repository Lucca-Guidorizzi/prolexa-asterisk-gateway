FROM alpine:3.20

# Instalar Asterisk e módulos essenciais de WebRTC, SRTP, Codecs e acme.sh para SSL Let's Encrypt
RUN apk add --no-cache \
    asterisk \
    asterisk-srtp \
    asterisk-curl \
    asterisk-speex \
    asterisk-sounds-en \
    openssl \
    ca-certificates \
    tzdata \
    bash \
    curl \
    socat

# Instalar acme.sh para emissão e renovação automática de certificado Let's Encrypt oficial via Cloudflare DNS
RUN curl https://get.acme.sh | sh -s email=suporte@altimatics.com

# Definir Timezone Brasil
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /etc/asterisk

# Criar diretórios de certificados e logs
RUN mkdir -p /etc/asterisk/keys /var/log/asterisk /var/spool/asterisk/monitor

# Copiar configurações
COPY ./config/ /etc/asterisk/
COPY ./entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expor portas de Sinalização e Mídia:
# 5060/udp - SIP tradicional (Tronco Operadora)
# 8089/tcp - WebSockets / WSS (WebRTC para Navegador)
# 10000-10100/udp - Mídia RTP/SRTP
EXPOSE 5060/udp 5060/tcp 8089/tcp 10000-10100/udp

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["asterisk", "-f", "-vvvddd"]
