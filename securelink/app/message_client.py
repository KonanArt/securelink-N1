import socket
from crypto.ecdh import *
from crypto.kdf import derive_key
from crypto.chacha20 import encrypt

HOST = 'server'
PORT = 5000

client = socket.socket()
client.connect((HOST, PORT))

priv, pub = generate_keypair()

client.sendall(serialize_public_key(pub))

server_pub_bytes = client.recv(1024)
server_pub = load_public_key(server_pub_bytes)

shared = compute_shared_secret(priv, server_pub)
key = derive_key(shared)

msg = b"Mensagem secreta da filial norte"
aad = b"cliente_norte"

nonce, ciphertext = encrypt(key, msg, aad)

print("Chave pública cliente:", serialize_public_key(pub))
print("Nonce:", nonce)
print("Ciphertext:", ciphertext)

data = aad + b'||' + nonce + ciphertext
client.sendall(len(data).to_bytes(4, 'big') + data)

print("Mensagem enviada!")

client.close()