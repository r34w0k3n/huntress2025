#!/usr/bin/env python3
from Crypto.Util.number import long_to_bytes

def modinv(a, m):
    return pow(a, -1, m)

def lagrange_at_zero(shares, prime):
    secret = 0
    for i, (xi, yi) in enumerate(shares):
        num = den = 1
        for j, (xj, _) in enumerate(shares):
            if i != j:
                num = (num * (-xj)) % prime
                den = (den * (xi - xj)) % prime
        secret = (secret + yi * num * modinv(den, prime)) % prime
    return secret
    
def main():
    prime = eval("0x%s" % open("prime.txt").read())
    
    shares = [o.strip().split("-") for o in open("shares.txt").readlines()]
    
    for n in range(len(shares)):
        shares[n][0] = int(shares[n][0])
        shares[n][1] = eval("0x%s" % shares[n][1])
        
    print(long_to_bytes(lagrange_at_zero(shares, prime)).decode())
    
if __name__ == "__main__":
    main()
