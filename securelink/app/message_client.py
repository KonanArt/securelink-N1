import socket
from crypto.ecdh import *
from crypto.kdf import derive_key
from crypto.chacha20 import encrypt

HOST = 'server'  # nome do container no docker
PORT = 5000

client = socket.socket()
client.connect((HOST, PORT))

# ECDH
priv, pub = generate_keypair()

# envia chave pública
client.send(serialize_public_key(pub))

# recebe chave servidor
server_pub_bytes = client.recv(1024)
server_pub = load_public_key(server_pub_bytes)

# segredo compartilhado
shared = compute_shared_secret(priv, server_pub)
key = derive_key(shared)

# mensagem
msg = b"Mensagem secreta da filial norte"

nonce, ciphertext = encrypt(key, msg)

client.send(nonce)
client.send(ciphertext)

print("Mensagem enviada!")

client.close()