# SecureLink VPN — Instruções de Execução

## 1. Pré-requisitos

* Docker Desktop instalado e em execução
* Versão mínima recomendada:

  * Docker: 24.x ou superior
  * Docker Compose: v2.x (integrado ao Docker Desktop)

Verificar instalação:

```
docker --version
docker compose version
```

---

## 2. Inicialização do Ambiente

Executar o comando abaixo na raiz do projeto:

```
docker compose up --build
```

Este comando irá:

* Construir todas as imagens Docker
* Inicializar a Autoridade Certificadora (CA)
* Gerar certificados digitais
* Subir o servidor OpenVPN
* Conectar os clientes à VPN
* Iniciar a aplicação

---

## 3. Verificar o Túnel VPN

Para verificar se o túnel foi estabelecido corretamente e se o cipher está correto:

```
docker logs server
```

Buscar no log por:

```
Data Channel: using cipher 'CHACHA20-POLY1305'
```

Isso confirma que o requisito de criptografia foi atendido.

---

## 4. Execução da Aplicação de Mensagens

### Iniciar servidor de mensagens:

```
docker exec -it app python message_server.py
```

### Em outro terminal, executar cliente:

```
docker exec -it app python message_client.py
```

---

## 5. Interpretação da Saída

Durante a execução, serão exibidos:

* Chaves públicas trocadas (ECDH)
* Nonce gerado
* Texto cifrado
* Mensagem decifrada

Exemplo esperado:

```
Mensagem enviada!
Mensagem recebida: Mensagem secreta da filial norte
```

Se a mensagem for exibida corretamente, significa que:

* A troca de chaves ECDH foi bem-sucedida
* A derivação de chave via HKDF funcionou
* A cifragem e autenticação com ChaCha20-Poly1305 foram válidas

---

## 6. Encerramento do Ambiente

Para parar todos os containers:

```
docker compose down
```

---

## 7. Limpeza Completa (Opcional)

Para remover containers, imagens e volumes:

```
docker system prune -a
```

⚠️ Este comando remove todos os recursos Docker não utilizados.
