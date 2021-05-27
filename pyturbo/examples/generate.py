block_size  = 5
num         = 32
bits        = 4
boundary    = 1
import numpy as np
SNR = [*np.linspace(-2,2,21)] # SNR from -2 to 2, with 21 datapoints inbetween
input_path = "../../data/golden.dat"
output_path = "../../data/ans.dat"
decode_path = "../../data/actual.dat"

import argparse
import random
#import numpy as np
import matplotlib.pyplot as plot
import copy
import os
random.seed(42)
np.random.seed(42)
try:
    os.remove(input_path)
except OSError:
    pass
try:
    os.remove(output_path)
except OSError:
    pass
try:
    os.remove(decode_path)
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
input_vector  = []
for n in range(num):
    # input_vector = np.random.randint(2, size=block_size)
    input_vector = np.array(list(np.binary_repr(n).zfill(5))).astype(np.int8)
    #print("original", [i for i in input_vector])
    encoded_vector = encoder.execute(input_vector)

    for s in SNR:
        # channel = AWGN(SNR)
        channel = AWGN(s)

        channel_vector = list(map(float, encoded_vector))
        channel_vector = channel.convert_to_symbols(channel_vector)
        channel_vector = channel.execute(channel_vector)

        uncoded_vector = list(map(float, input_vector))
        uncoded_vector = channel.convert_to_symbols(uncoded_vector)
        uncoded_vector = channel.execute(uncoded_vector)

        new_vector = convert(channel_vector, bits, boundary)
        #print(new_vector)
        new_vector = np.array([round(i*7) for i in new_vector])
        # print("new_vector", new_vector)
        #print("input:", input_vector)
        #print("encoded", encoded_vector)
        #print("channel:", channel_vector)
        #print("new:", new_vector)
        reshuffled = np.concatenate((new_vector[::3], new_vector[1::3], new_vector[2::3]))
        
        # print(new_vector[::3],new_vector[::3][::-1])

        # reshuffle = np.zeros((1,84))
        
        #print("output:", end=" ")
        
        with open(input_path, "a+") as f:
            inputs = []
            for i in reshuffled:
                # print(int(i), bins(int(i), 4))
                inputs.append(bins(int(i), 4))
            # print(inputs)
            text = ''
            for i in range(4):
                for string in inputs:
                    text = text + string[i]
                    # print(string)
            # print(text, " ", text[0:21], " ", text[21:42], " ", text[42:63], " ", text[63:84])
            for i in text:
                # print(bins(int(i), 4), end="", file=f)
                print(i, end="", file=f)
            #print()
            print(file=f)
        ans = decoder.execute(new_vector)
        ans = [int(sym >= 0) for sym in ans[:5]]
        decoder.reset()
        with open(decode_path, "a+") as f:
            for i in ans:
                # print(bins(int(i), 4), end="", file=f)
                print(i, end="", file=f)
            print(file=f)
        with open(output_path, "a+") as f:
            for i in input_vector:
                # print(bins(int(i), 4), end="", file=f)
                print(i, end="", file=f)
            print(file=f)
        #print(f"SNR = {s}", [int(b >= 0) for b in ans[:5]])
        