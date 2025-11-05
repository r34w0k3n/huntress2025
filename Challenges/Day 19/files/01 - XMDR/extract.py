#!/usr/bin/env python3
import sqlite3
import re
import urllib.parse
from codecs import decode

def main():
    conn = sqlite3.connect("History")
    curs = conn.cursor()
    curs.execute("SELECT * FROM urls")
    rows = curs.fetchall()
    conn.close()

    for item in rows:
        if "STARTCOMMAND" not in item[1]:
            continue
            
        data = re.findall("STARTCOMMAND(.+?)ENDCOMMAND", item[1])[0]
        data = urllib.parse.unquote(data)
        
        command = decode(data.encode(), "uu").decode().strip()
        
        print(command)
    
if __name__ == "__main__":
    main()
