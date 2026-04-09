import os
from cryptography.hazmat.primitives.ciphers.aead import ChaCha20Poly1305

def encrypt(key, plaintext, aad=b""):
    nonce = os.urandom(12)
    cipher = ChaCha20Poly1305(key)
    ciphertext = cipher.encrypt(nonce, plaintext, aad)
    return nonce, ciphertext

def decrypt(key, nonce, ciphertext, aad=b""):
    cipher = ChaCha20Poly1305(key)
    return cipher.decrypt(nonce, ciphertext, aad)