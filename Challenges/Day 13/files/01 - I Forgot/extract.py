#!/usr/bin/env python3
import os
import sys
import struct

EOCD_SIG = b'PK\x05\x06'
CD_FILE_HEADER_SIG = b'PK\x01\x02'
LOCAL_FILE_SIG = b'PK\x03\x04'
ZIP64_EOCD_SIG = b'PK\x06\x06'

def find_all(data, needle):
    i = 0
    while True:
        i = data.find(needle, i)
        if i == -1:
            break
        yield i
        i += 1

def parse_eocd(data, pos):
    if pos + 22 > len(data):
        return None
    chunk = data[pos:pos+22]
    sig, dnum, dstart, n1, n2, cd_size, cd_offset, comment_len = struct.unpack('<4sHHHHIIH', chunk)
    if sig != EOCD_SIG:
        return None
    return {
        'pos': pos,
        'cd_size': cd_size,
        'cd_offset': cd_offset,
        'comment_len': comment_len,
        'eocd_total_size': 22 + comment_len
    }

def parse_central_directory_entries(data, cd_start, cd_size):
    entries = []
    p = cd_start
    cd_end = cd_start + cd_size
    while p + 46 <= cd_end:
        if data[p:p+4] != CD_FILE_HEADER_SIG:
            return None
        try:
            (sig, ver_made, ver_need, flags, comp, modt, modd,
             crc32, comp_size, uncomp_size,
             fname_len, extra_len, comment_len,
             diskstart, int_attr, ext_attr, local_hdr_off) = struct.unpack_from('<4sHHHHHHIIIHHHHLH I', data, p)
        except Exception:
            local_hdr_off = struct.unpack_from('<I', data, p + 42)[0]
            fname_len = struct.unpack_from('<H', data, p + 28)[0]
            extra_len = struct.unpack_from('<H', data, p + 30)[0]
            comment_len = struct.unpack_from('<H', data, p + 32)[0]
        entries.append({
            'cd_entry_pos': p,
            'local_header_offset': local_hdr_off,
            'fname_len': fname_len,
            'extra_len': extra_len,
            'comment_len': comment_len
        })
        p += 46 + entries[-1]['fname_len'] + entries[-1]['extra_len'] + entries[-1]['comment_len']
    return entries

def safe_unpack(fmt, data, offset):
    try:
        return struct.unpack_from(fmt, data, offset)
    except Exception:
        return None

def try_extract_archive(data, eocd_pos, outdir, index):
    eocd = parse_eocd(data, eocd_pos)
    if not eocd:
        return False
    cd_size = eocd['cd_size']
    cd_offset = eocd['cd_offset']
    comment_len = eocd['comment_len']
    eocd_total_size = eocd['eocd_total_size']

    archive_start = eocd_pos - (cd_offset + cd_size)
    if archive_start < 0:
        return False

    cd_start = archive_start + cd_offset
    cd_end = cd_start + cd_size
    if cd_end > eocd_pos:
        return False
    if data[cd_start:cd_start+4] not in (CD_FILE_HEADER_SIG,):
        found = False
        for delta in range(-64, 65):
            p = cd_start + delta
            if 0 <= p < len(data)-4 and data[p:p+4] == CD_FILE_HEADER_SIG:
                cd_start = p
                found = True
                break
        if not found:
            return False

    entries = parse_central_directory_entries(data, cd_start, cd_size)
    if entries is None or len(entries) == 0:
        return False

    for ent in entries:
        local_abs = archive_start + ent['local_header_offset']
        if not (0 <= local_abs < len(data)-4):
            return False
        if data[local_abs:local_abs+4] != LOCAL_FILE_SIG:
            return False

    eocd_end_pos = eocd_pos + eocd_total_size
    out_name = os.path.join(outdir, f'found_zip_{index:04d}.zip')
    with open(out_name, 'wb') as out:
        out.write(data[archive_start:eocd_end_pos])
    print(f'[+] Extracted {out_name} (start=0x{archive_start:x} end=0x{eocd_end_pos:x}, {len(entries)} entries)')
    return True

def main():
    if len(sys.argv) < 3:
        print("Usage: extract_zips_from_mem.py <memory_image> <out_dir>")
        sys.exit(1)
    memfile = sys.argv[1]
    outdir = sys.argv[2]
    os.makedirs(outdir, exist_ok=True)
    with open(memfile, 'rb') as f:
        data = f.read()

    eocd_positions = list(find_all(data, EOCD_SIG))
    print(f'Found {len(eocd_positions)} EOCD candidate(s). Scanning...')

    extracted = 0
    used_eocd_positions = set()
    for i, pos in enumerate(eocd_positions):
        if any(abs(pos - p) < 4 for p in used_eocd_positions):
            continue
        ok = try_extract_archive(data, pos, outdir, extracted+1)
        if ok:
            extracted += 1
            used_eocd_positions.add(pos)
    print(f'Done. Extracted {extracted} ZIP(s).')

if __name__ == '__main__':
    main()
