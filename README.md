# 📞 Asterisk WebRTC PABX Gateway (Prolexa CRM & GoSat)

Servidor PABX Asterisk WebRTC de alta performance empacotado em Docker, pronto para implantação em VPS com **Portainer** ou **Docker Compose**.

Ele atua como o conversor e gateway de borda entre o navegador web e operadoras tradicionais:
- **Ponta Navegador (CRM):** Conecta via WebSockets seguros (**WSS**, porta `8089`) com **WebRTC DTLS-SRTP** (codecs Opus e PCMA).
- **Ponta Operadora (GoSat):** Converte a sinalização para **SIP tradicional UDP** (porta `5060`) e áudio **RTP G.711a (PCMA)**.

---

## 🌐 Endereço DNS Configurado na Cloudflare

O subdomínio oficial já foi criado e apontado para a sua VPS:
- **FQDN:** `pabx.altimatics.com`
- **Destino IP:** `69.62.97.253`
- **Porta WSS:** `8089` (ex: `wss://pabx.altimatics.com:8089/ws`)

---

## 🚀 Como Subir no Portainer (Passo a Passo)

### 1. Criar Stack no Portainer
1. No painel do seu Portainer (`https://portainer.altimatics.com` ou porta `9443`), acesse **Stacks** -> **Add stack**.
2. Dê o nome de: `prolexa-pabx`.
3. Escolha a opção **Repository**:
   - **Repository URL:** `https://github.com/Lucca-Guidorizzi/prolexa-asterisk-gateway.git`
   - **Repository reference:** `refs/heads/main`
   - **Compose path:** `docker-compose.yml`

### 2. Configurar as Variáveis de Ambiente
Na área **Environment variables** do Portainer, preencha:

```env
PUBLIC_IP=69.62.97.253
WSS_PORT=8089

TRUNK_HOST=189.3.77.93
TRUNK_PORT=5060
TRUNK_USER=SEU_USUARIO_GOSAT
TRUNK_PASSWORD=SUA_SENHA_GOSAT

WEBRTC_EXT_USER=1001
WEBRTC_EXT_PASS=ProlexaSecret1001@
```

### 3. Fazer o Deploy
Clique em **Deploy the stack**. O Portainer fará o download da imagem base, aplicará as configurações PJSIP e iniciará o container.

---

## 🔒 Portas de Firewall necessárias na VPS:
Certifique-se de que o firewall da VPS libere as seguintes portas:
- `8089/tcp`: WebSockets WSS do Asterisk
- `5060/udp` e `5060/tcp`: Sinalização SIP para a GoSat
- `10000-10100/udp`: Tráfego de áudio RTP

---

## 🎧 Conectando no Prolexa CRM:

Após a stack estar ativa:
1. Abra o Prolexa CRM no navegador (`https://prolexa-adv-crm.vercel.app` ou seu domínio).
2. Acesse **Configurações** -> **PABX** -> aba **Conexão SIP**:
   - **Servidor SIP WSS:** `wss://pabx.altimatics.com:8089/ws` (ou `wss://69.62.97.253:8089/ws`)
   - **Usuário SIP:** `1001`
   - **Senha SIP:** `ProlexaSecret1001@`
   - **Domínio SIP:** `pabx.altimatics.com`
3. Clique em **Testar Conexão** -> O status ficará verde (**Conectado ✓**).
4. Disque `*43` no discador para fazer o teste de eco de voz.
5. Disque qualquer telefone comercial (DDD + Número) para falar com o cliente pelo tronco da GoSat.

---
*Assinado por: **Lagana Flow***
