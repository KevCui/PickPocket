#! /usr/bin/env python3
import sys
from sqlite3 import dbapi2
from Crypto.Protocol.KDF import PBKDF2
from Crypto.Cipher import AES


def main(db):
    conn = dbapi2.connect(db)
    query = 'SELECT name,encrypted_value FROM cookies \
            WHERE host_key="getpocket.com"'
    rows = conn.cursor().execute(query)

    for r in rows.fetchall():
        print(r[0] + '=' + decrypt(r[1]) + ';')


def clean(x):
    return x[:-x[-1]].decode('utf8')


def decrypt(blob):
    # Code modified from https://stackoverflow.com/a/23727331/8272771
    encrypted_value = blob[3:]
    salt = b'saltysalt'
    iv = b' ' * 16
    length = 16
    password = 'peanuts'.encode('utf8')
    iterations = 1

    key = PBKDF2(password, salt, length, iterations)
    cipher = AES.new(key, AES.MODE_CBC, IV=iv)

    decrypted = cipher.decrypt(encrypted_value)

    return clean(decrypted)


if __name__ == '__main__':
    main(sys.argv[1])
