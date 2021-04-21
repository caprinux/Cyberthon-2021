from binascii import hexlify

def preprocess(data):
    return ''.join([str(x).zfill(3) for x in list(data)])


def encode(data):
    y = list(data)
    x = y.pop(0)
    w = 1
    v = ''
    while y:
        z = y.pop(0)
        if x == z:
            if w < 9:
                w += 1
        else:
            v += f"{w}{x}"
            x = z
            w = 1
        if not y:
            v += f"{w}{x}"

    return v


with open('flag.txt', 'rb') as (f):
    flag = f.read()
d = preprocess(flag)
for i in range(24):
    d = encode(d)

with open('flag.txt.encrypted', 'w') as (f):
    f.write(d)

