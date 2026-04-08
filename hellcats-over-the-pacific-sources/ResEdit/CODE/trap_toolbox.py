import glob, pathlib, collections, math

def count_sub(data: bytes, pat: bytes) -> int:
    c = 0
    i = 0
    while True:
        j = data.find(pat, i)
        if j < 0: return c
        c += 1
        i = j + 1

def entropy(data: bytes) -> float:
    if not data: return 0.0
    freq = collections.Counter(data)
    n = len(data)
    return -sum((k/n)*math.log2(k/n) for k in freq.values())

print("file,size,entropy,linkA6(4e56),rts(4e75),bsr(4eba),trap_Ax(0xA?),strings>=4")
for f in sorted(glob.glob("ID*.bin")):
    p = pathlib.Path(f)
    b = p.read_bytes()
    link = count_sub(b, bytes.fromhex("4e56"))
    rts  = count_sub(b, bytes.fromhex("4e75"))
    bsr  = count_sub(b, bytes.fromhex("4eba"))
    traps = sum(1 for x in b if (x & 0xF0) == 0xA0)  # rough
    # rough strings count
    s = 0
    run = 0
    for ch in b:
        if 32 <= ch <= 126:
            run += 1
        else:
            if run >= 4: s += 1
            run = 0
    if run >= 4: s += 1
    print(f"{f},{len(b)},{entropy(b):.2f},{link},{rts},{bsr},{traps},{s}")
