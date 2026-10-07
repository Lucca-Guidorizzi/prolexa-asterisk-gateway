# 📞 Asterisk WebRTC PABX Gateway (Prolexa CRM & GoSat)

Servidor PABX Asterisk WebRTC de alta performance pré-compilado e empacotado em Docker, pronto para implantação em VPS com **Portainer** (seja no modo **Docker Swarm** ou **Standalone**).

Ele atua como o conversor e gateway de borda entre o navegador web e a operadora:
- **Ponta Navegador (CRM):** Conecta via WebSockets seguros (**WSS**, porta `8089`) com **WebRTC DTLS-SRTP** (codecs Opus e PCMA).
- **Ponta Operadora (GoSat):** Converte a sinalização para **SIP tradicional UDP** (porta `5060`) e áudio **RTP G.711a (PCMA)**.

---

## 🌐 Endereço DNS Configurado na Cloudflare

O subdomínio oficial já está ativo e apontado diretamente para a VPS:
- **FQDN:** `pabx.altimatics.com`
- **Destino IP:** `69.62.97.253`
- **Proxy Status:** `DNS only` (obrigatório para permitir tráfego SIP/WSS e UDP sem bloqueios).
- **Endpoint WebSockets seguro:** `wss://pabx.altimatics.com:8089/ws`

---

## 🚀 Como Subir no Portainer (Passo a Passo)

Como o seu Portainer opera em modo **Docker Swarm**, a stack agora utiliza a imagem oficial pré-compilada:
`ghcr.io/lucca-guidorizzi/prolexa-asterisk-gateway:latest` (Pública, 100% pronta para download).

### Opção 1: Via Web Editor no Portainer (Método mais rápido)
1. No Portainer, acesse **Stacks** -> **Add stack**.
2. Nomeie como: `prolexa-pabx`.
3. Escolha **Web editor** e cole o seguinte YAML:

```yaml
version: '3.8'

services:
  asterisk-gateway:
    image: ghcr.io/lucca-guidorizzi/prolexa-asterisk-gateway:latest
    environment:
      PUBLIC_IP: ${PUBLIC_IP:-69.62.97.253}
      TRUNK_HOST: ${TRUNK_HOST:-189.3.77.93}
      TRUNK_PORT: ${TRUNK_PORT:-5060}
      TRUNK_USER: ${TRUNK_USER}
      TRUNK_PASSWORD: ${TRUNK_PASSWORD}
      WEBRTC_EXT_USER: ${WEBRTC_EXT_USER:-1001}
      WEBRTC_EXT_PASS: ${WEBRTC_EXT_PASS:-ProlexaSecret1001@}
    ports:
      # WSS para WebSockets WebRTC do Navegador (Porta 8443 compatível com Proxy SSL Cloudflare)
      - target: 8089
        published: 8443
        protocol: tcp
        mode: host
      # SIP UDP e TCP para a Operadora GoSat
      - target: 5060
        published: 5060
        protocol: udp
        mode: host
      - target: 5060
        published: 5060
        protocol: tcp
        mode: host
      # Portas RTP de áudio (10000-10010)
      - target: 10000
        published: 10000
        protocol: udp
        mode: host
      - target: 10001
        published: 10001
        protocol: udp
        mode: host
      - target: 10002
        published: 10002
        protocol: udp
        mode: host
      - target: 10003
        published: 10003
        protocol: udp
        mode: host
      - target: 10004
        published: 10004
        protocol: udp
        mode: host
      - target: 10005
        published: 10005
        protocol: udp
        mode: host
      - target: 10006
        published: 10006
        protocol: udp
        mode: host
      - target: 10007
        published: 10007
        protocol: udp
        mode: host
      - target: 10008
        published: 10008
        protocol: udp
        mode: host
      - target: 10009
        published: 10009
        protocol: udp
        mode: host
      - target: 10010
        published: 10010
        protocol: udp
        mode: host
    volumes:
      - asterisk-recordings:/var/spool/asterisk/monitor
      - asterisk-logs:/var/log/asterisk
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure

volumes:
  asterisk-recordings:
  asterisk-logs:
```

### Opção 2: Via Git Repository
Se preferir apontar o repositório diretamente:
- **Repository URL:** `https://github.com/Lucca-Guidorizzi/prolexa-asterisk-gateway.git`
- **Repository reference:** `refs/heads/main`
- **Compose path:** `docker-compose.yml`

### Preencher as Variáveis de Ambiente no Portainer:
Na seção **Environment variables**:
```env
PUBLIC_IP=69.62.97.253
TRUNK_HOST=189.3.77.93
TRUNK_PORT=5060
TRUNK_USER=SEU_LOGIN_GOSAT
TRUNK_PASSWORD=SUA_SENHA_GOSAT
WEBRTC_EXT_USER=1001
WEBRTC_EXT_PASS=ProlexaSecret1001@
```

Clique em **Deploy the stack**. O Swarm baixará a imagem oficial do GHCR e o container subirá imediatamente sem erros!

---

## 🎧 Conectando no Prolexa CRM:

1. Abra o Prolexa CRM: [https://prolexa-adv-crm.vercel.app](https://prolexa-adv-crm.vercel.app)
2. Vá em **Configurações** -> **PABX** -> aba **Conexão SIP**:
   - **Servidor SIP WSS:** `wss://pabx.altimatics.com:8443/ws`
   - **Usuário SIP:** `1001`
   - **Senha SIP:** `ProlexaSecret1001@`
   - **Domínio SIP:** `pabx.altimatics.com`
3. Clique em **Salvar** e **Testar Conexão** -> Aparecerá `Conectado ✓`.
4. Disque `*43` para o teste de eco e confirme o áudio no navegador.
5. Disque DDD + Número para falar com qualquer cliente pelo tronco GoSat.

---
*Assinado por: **Lagana Flow***
