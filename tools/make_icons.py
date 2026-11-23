"""Build Mage Network icon assets. Pure Python, no dependencies.

    python tools/make_icons.py path/to/icon.png   # from your artwork (PNG)
    python tools/make_icons.py --placeholder      # simple generated placeholder

Writes:
    MageNetwork/Media/icon.tga   128x128, used in game (minimap, window, addon list)
    docs/assets/icon.png         256x256, used by the GitHub README
"""
import math
import os
import struct
import sys
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TGA_OUT = os.path.join(ROOT, "MageNetwork", "Media", "icon.tga")
PNG_OUT = os.path.join(ROOT, "docs", "assets", "icon.png")


# --------------------------------------------------------------------------- PNG read
def read_png(path):
    data = open(path, "rb").read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        sys.exit("Not a PNG file: " + path)
    pos, idat, palette, trns = 8, b"", None, None
    while pos < len(data):
        (length,) = struct.unpack(">I", data[pos:pos + 4])
        kind = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + length]
        pos += 12 + length
        if kind == b"IHDR":
            w, h, depth, ctype, _, _, interlace = struct.unpack(">IIBBBBB", chunk)
        elif kind == b"PLTE":
            palette = chunk
        elif kind == b"tRNS":
            trns = chunk
        elif kind == b"IDAT":
            idat += chunk
        elif kind == b"IEND":
            break
    if depth != 8 or interlace != 0:
        sys.exit("Please export an 8-bit, non-interlaced PNG.")
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[ctype]
    stride = w * channels
    raw = zlib.decompress(idat)
    rows, prev, i = [], bytearray(stride), 0
    for _ in range(h):
        ftype = raw[i]
        line = bytearray(raw[i + 1:i + 1 + stride])
        i += 1 + stride
        for x in range(stride):
            a = line[x - channels] if x >= channels else 0
            b = prev[x]
            c = prev[x - channels] if x >= channels else 0
            if ftype == 1:
                line[x] = (line[x] + a) & 255
            elif ftype == 2:
                line[x] = (line[x] + b) & 255
            elif ftype == 3:
                line[x] = (line[x] + ((a + b) >> 1)) & 255
            elif ftype == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pred = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                line[x] = (line[x] + pred) & 255
        rows.append(line)
        prev = line
    px = []
    for line in rows:
        for x in range(w):
            o = x * channels
            if ctype == 6:
                px.append(tuple(line[o:o + 4]))
            elif ctype == 2:
                px.append((line[o], line[o + 1], line[o + 2], 255))
            elif ctype == 0:
                px.append((line[o],) * 3 + (255,))
            elif ctype == 4:
                px.append((line[o],) * 3 + (line[o + 1],))
            else:
                idx = line[o]
                r, g, b = palette[idx * 3:idx * 3 + 3]
                a = trns[idx] if trns and idx < len(trns) else 255
                px.append((r, g, b, a))
    return w, h, px


# --------------------------------------------------------------------------- resize
def square_resize(w, h, px, size):
    side = min(w, h)
    ox, oy = (w - side) // 2, (h - side) // 2
    out = []
    step = side / size
    for y in range(size):
        y0, y1 = int(oy + y * step), max(int(oy + (y + 1) * step), int(oy + y * step) + 1)
        for x in range(size):
            x0, x1 = int(ox + x * step), max(int(ox + (x + 1) * step), int(ox + x * step) + 1)
            r = g = b = a = n = 0
            for yy in range(y0, y1):
                base = yy * w
                for xx in range(x0, x1):
                    pr, pg, pb, pa = px[base + xx]
                    r += pr * pa; g += pg * pa; b += pb * pa; a += pa; n += 1
            if a:
                out.append((r // a, g // a, b // a, a // n))
            else:
                out.append((0, 0, 0, 0))
    return out


# --------------------------------------------------------------------------- writers
def write_tga(path, size, px):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    header = struct.pack("<BBBHHBHHHHBB", 0, 0, 2, 0, 0, 0, 0, 0, size, size, 32, 0x28)
    body = bytearray()
    for r, g, b, a in px:
        body += bytes((b, g, r, a))
    with open(path, "wb") as f:
        f.write(header + bytes(body))


def write_png(path, size, px):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    raw = bytearray()
    for y in range(size):
        raw.append(0)
        for r, g, b, a in px[y * size:(y + 1) * size]:
            raw += bytes((r, g, b, a))

    def chunk(kind, payload):
        c = struct.pack(">I", len(payload)) + kind + payload
        return c + struct.pack(">I", zlib.crc32(kind + payload) & 0xFFFFFFFF)

    ihdr = struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr)
                + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b""))


# --------------------------------------------------------------------------- placeholder
def placeholder(size):
    """A glowing arcane portal ring in mage blue."""
    blue = (63, 199, 235)
    out = []
    c = (size - 1) / 2
    for y in range(size):
        for x in range(size):
            dx, dy = (x - c) / c, (y - c) / c
            d = math.hypot(dx, dy)
            ang = math.atan2(dy, dx)
            if d > 1.0:
                out.append((0, 0, 0, 0))
                continue
            edge = min(1.0, (1.0 - d) * size / 3)          # anti-aliased rim
            t = d                                          # dark navy background
            r, g, b = 10 + 12 * (1 - t), 14 + 20 * (1 - t), 24 + 40 * (1 - t)
            ring = math.exp(-((d - 0.80) / 0.035) ** 2)    # outer ring
            swirl = math.exp(-((d - (0.30 + 0.06 * math.sin(ang * 3))) / 0.09) ** 2) * 0.8
            core = math.exp(-(d / 0.22) ** 2)              # bright center
            glow = min(1.0, ring + swirl + core * 0.9)
            r += (blue[0] - r) * glow + 255 * core * 0.5
            g += (blue[1] - g) * glow + 255 * core * 0.5
            b += (blue[2] - b) * glow + 255 * core * 0.3
            out.append((min(255, int(r)), min(255, int(g)), min(255, int(b)), int(255 * edge)))
    return out


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    if sys.argv[1] == "--placeholder":
        big = placeholder(256)
        small = placeholder(128)
    else:
        w, h, px = read_png(sys.argv[1])
        print("Read %dx%d, resizing..." % (w, h))
        big = square_resize(w, h, px, 256)
        small = square_resize(w, h, px, 128)
    write_tga(TGA_OUT, 128, small)
    write_png(PNG_OUT, 256, big)
    print("Wrote", os.path.relpath(TGA_OUT, ROOT))
    print("Wrote", os.path.relpath(PNG_OUT, ROOT))


if __name__ == "__main__":
    main()
