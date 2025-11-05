#!/usr/bin/env python3
import base64

def main():
    segments = [
        "Wm14aFozczNOak0wTWpZNVlXVmhPRGs9",
        "WXpBME16UmtOVGt3TWpnPQ==",
        "TWpVeU9UWXlORGN3ZlE9PQ=="
    ]

    flag = ""

    for item in segments:
        # Not a typo. They're double base64 encoded.
        item = base64.b64decode(item)
        item = base64.b64decode(item)
        flag += item.decode()

    print(flag)
    
if __name__ == "__main__":
    main()
