import socket
from crypto.ecdh import *
from crypto.kdf import derive_key
from crypto.chacha20 import decrypt

HOST = '0.0.0.0'
PORT = 5000

server = socket.socket()
server.bind((HOST, PORT))
server.listen(1)

print("Servidor aguardando conexão...")

conn, addr = server.accept()
print("Cliente conectado:", addr)

# ECDH
priv, pub = generate_keypair()

# recebe chave cliente
client_pub_bytes = conn.recv(1024)
client_pub = load_public_key(client_pub_bytes)

# envia chave servidor
conn.send(serialize_public_key(pub))

# segredo compartilhado
shared = compute_shared_secret(priv, client_pub)
key = derive_key(shared)

# recebe mensagem
nonce = conn.recv(12)
ciphertext = conn.recv(1024)

try:
    plaintext = decrypt(key, nonce, ciphertext)
    print("Mensagem recebida:", plaintext.decode())
except Exception as e:
    print("Erro na autenticação:", e)

conn.close()