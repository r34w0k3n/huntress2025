#!/usr/bin/env python3
import pyshark

def main():
    capture = pyshark.FileCapture("bussing_around.pcapng")
    bits = ""

    for packet in capture:
        if "MODBUS" not in packet:
            continue
        
        if packet.ip.src != "172.20.10.6":
            continue
         
        if packet.modbus.func_code != "6":
            continue
         
        if packet.modbus.regnum16 == "0":
            bits += packet.modbus.regval_uint16
    
    with open("out.bin", "wb") as fout:
        for n in range(0, len(bits), 8):
            fout.write(int(bits[n:n+8], 2).to_bytes())

if __name__ == "__main__":
    main()
