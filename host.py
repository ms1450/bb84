import qsharp
from Lab5 import MainFunction
import base64
import os
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC


def deriveKey(sharedKey):
    salt = os.urandom(16)
    kdf = PBKDF2HMAC(algorithm=hashes.SHA256(),length=32,salt=salt,iterations=100000,)
    key = base64.urlsafe_b64encode(kdf.derive(sharedKey))
    return key


def encrypt(key, data):
    f = Fernet(key)
    return f.encrypt(data.encode())


def decrypt(key, token):
    f = Fernet(key)
    return f.decrypt(token)

# Run Q# Program and Get Sifted Key
siftedKey = MainFunction.simulate()
print("Sifted Key: " + str(siftedKey))
key = deriveKey(bytes(siftedKey))
# Encrypt and Decrypt a String
string = "hello quantum world"
encrypted = encrypt(key, string)
print("Encrypted Data: " + str(encrypted))
decrypted = decrypt(key, encrypted)
print("Decrypted Data: " + decrypted.decode())
