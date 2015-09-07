#!/usr/bin/python3

def interleave8(a, b):
    rv = 0
    for bit in range(8):
        rv |= ((a >> bit) & 1) << (bit*2+0)
        rv |= ((b >> bit) & 1) << (bit*2+1)
    return rv

def interleave_ram(d_in):
    '''
    Input: 512 bytes
    Output: 16 256-bit words
    '''
    d_out = [0] * 16
    for ptr in range(256):
        d_out[ptr >> 4] |= interleave8(d_in[ptr], d_in[ptr|256]) << ((ptr&15)*16)
    return d_out

s = b'hello\n'

d = bytearray(512)
ptr = 0

d[ptr] = 0x07 # MOV IMM r3,3
ptr += 1
d[ptr] = len(s)
ptr += 1

d[ptr] = 0x04 # MOV IMM r0,0x00
ptr += 1
d[ptr] = 0x00
ptr += 1

d[ptr] = 0x05 # MOV IMM r1,0x01
ptr += 1
d[ptr] = 0x00
ptr += 1

d[ptr] = 0x06 # MOV IMM r2,
ptr += 1
d[ptr] = ord('x')
ptr += 1

begin_loop_ptr = ptr

d[ptr] = 0xC8 # LD r2, [{r1,r0}] (offset 0x100)
ptr += 1
d[ptr] = 0x0A # SEND r2
ptr += 1

d[ptr] = 0x18 # INC r0 (pointer)
ptr += 1

d[ptr] = 0x0F # DEC r3
ptr += 1
d[ptr] = 0x13 # JNZ r3,begin_loop
ptr += 1
d[ptr] = begin_loop_ptr
ptr += 1

d[ptr] = 0x00 # Back to IDLE
ptr += 1

d[0x100:0x100+len(s)] = s

import binascii
print(binascii.b2a_hex(d))

v = interleave_ram(d)

for l in range(16):
    print(".INIT_%X(256'h%064x)," % (l,v[l]))

