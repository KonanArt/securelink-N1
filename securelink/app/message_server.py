import socket
from crypto.ecdh import *
from crypto.kdf import derive_key
from crypto.chacha20 import decrypt
from cryptography.exceptions import InvalidTag

HOST = '0.0.0.0'
PORT = 5000

server = socket.socket()
server.bind((HOST, PORT))
server.listen(1)

print("Servidor aguardando conexão...")

conn, addr = server.accept()
print("Cliente conectado:", addr)

priv, pub = generate_keypair()

client_pub_bytes = conn.recv(1024)
client_pub = load_public_key(client_pub_bytes)

conn.sendall(serialize_public_key(pub))

shared = compute_shared_secret(priv, client_pub)
key = derive_key(shared)

data_len = int.from_bytes(conn.recv(4), 'big')
data = conn.recv(data_len)

aad, rest = data.split(b'||', 1)
nonce = rest[:12]
ciphertext = rest[12:]

print("Chave pública cliente:", client_pub_bytes)
print("Nonce recebido:", nonce)
print("Ciphertext recebido:", ciphertext)
print("AAD:", aad)

try:
    plaintext = decrypt(key, nonce, ciphertext, aad)
    print("Mensagem recebida:", plaintext.decode())
except InvalidTag:
    print("Falha de autenticação! Dados foram adulterados.")

conn.close()