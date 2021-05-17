block_size  = 5
num         = 1
bits        = 4
boundary    = 1
SNR = -1
write_path = "golden.dat"

import argparse
import random
import numpy as np
import matplotlib.pyplot as plot
import copy
import os
random.seed(42)
np.random.seed(42)
try:
    os.remove(write_path)
except OSError:
    pass

from turbo import TurboEncoder
from turbo import AWGN
from turbo import TurboDecoder
from turbo import SISODecoder

def bins(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)

def convert(a, bit, bound):
    # a is a np.array
    # -----(-1)--|----|----|--(1)-----
    segments = 2**bit-1
    arr = copy.copy(a)
    segment_len = (bound - (-bound)) / (segments-1)
    arr[a > bound - segment_len * 0.5] = bound
    arr[a < -bound + segment_len * 0.5] = -bound
    for i in range(2, segments): # 2 to num of segments -1
        arr[(a > -bound + segment_len * (i-2 + 1/2)) & (a < -bound + segment_len * (i-1 + 1/2))] = -bound + segment_len * (i-1)
    return arr

interleaver = random.sample(range(0, block_size), block_size)
encoder = TurboEncoder(interleaver)
decoder = TurboDecoder(interleaver)

for n in range(num):
    input_vector = np.random.randint(2, size=block_size)
    encoded_vector = encoder.execute(input_vector)
    channel = AWGN(SNR)

    channel_vector = list(map(float, encoded_vector))
    channel_vector = channel.convert_to_symbols(channel_vector)
    channel_vector = channel.execute(channel_vector)

    uncoded_vector = list(map(float, input_vector))
    uncoded_vector = channel.convert_to_symbols(uncoded_vector)
    uncoded_vector = channel.execute(uncoded_vector)

    new_vector = convert(channel_vector, bits, boundary)
    #print(new_vector)
    new_vector = np.array([round(i*7) for i in new_vector])
    #print(new_vector)
    #print("input:", input_vector)
    #print("encoded", encoded_vector)
    #print("channel:", channel_vector)
    #print("new:", new_vector)
    reshuffled = np.concatenate((new_vector[::3], new_vector[1::3], new_vector[2::3]))
    #print("output:", end=" ")
    
    with open(write_path, "a+") as f:
        for i in reshuffled:
            print(int(i), bins(int(i), 4))
            print(bins(int(i), 4), end="", file=f)
        print()
        print(file=f)

    decoder.execute(new_vector)
    decoder.reset()