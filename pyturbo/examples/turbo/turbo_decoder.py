#
# Turbo Decoder
#

import numpy as np

from .siso_decoder import SISODecoder

def bins(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)
class TurboDecoder:
    @staticmethod
    def demultiplex(a, b, extrinsic):
        return list(zip(a, b, extrinsic))

    @staticmethod
    def early_exit(LLR, LLR_ext):
        LLR = [int(s > 0) for s in LLR]
        LLR_ext = [int(s > 0) for s in LLR_ext]
        if(LLR == LLR_ext):
            print([int(s > 0) for s in LLR])
        return LLR == LLR_ext

    def __init__(self, interleaver, tail_bits=2, max_iter=16):
        self.interleaver = interleaver
        self.block_size = len(self.interleaver)
        self.tail_bits = tail_bits
        self.max_iter = max_iter

        self.decoders = 2 * [SISODecoder(self.block_size + tail_bits)]

        self.reset()

    def reset(self):
        for d in self.decoders:
            d.reset()

        self.LLR_ext = np.zeros(self.block_size + self.tail_bits, dtype=float)

    def interleave(self, vector):
        interleaved = np.zeros(len(vector), dtype=int)
        interleaved[:self.block_size:] = vector[self.interleaver]

        return interleaved

    def deinterleave(self, vector):
        deinterleaved = np.zeros(len(vector), dtype=int)
        deinterleaved[self.interleaver] = vector[:self.block_size:]

        return deinterleaved

    def iterate(self, vector, i):
        input_tuples = self.demultiplex(vector[::3], vector[1::3], self.LLR_ext)
        print("vector[::3]", vector[::3], [bins(int(i), 4) for i in vector[::3]])
        print("vector[1::3]", vector[1::3], [bins(int(i), 4) for i in vector[1::3]])
        print("self.LLR_ext", self.LLR_ext, [bins(int(i), 10) for i in self.LLR_ext])
        print("=====================================")
        LLR_1 = self.decoders[0].execute(input_tuples, i)

        print("LLR_1 binary: ", LLR_1, [bins(int(i), 10) for i in LLR_1])
        LLR_1 = LLR_1 - self.LLR_ext - 2 * vector[::3]
        
        LLR_interleaved = self.interleave(LLR_1)
        input_interleaved = self.interleave(vector[::3])
        
        print("input_interleaved", input_interleaved, [bins(int(i), 4) for i in input_interleaved])
        print("vector[2::3]", vector[2::3], [bins(int(i), 4) for i in vector[2::3]])
        print("LLR_interleaved", LLR_interleaved, [bins(int(i), 10) for i in LLR_interleaved])
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        input_tuples = self.demultiplex(input_interleaved, vector[2::3], LLR_interleaved)

        LLR_2 = self.decoders[1].execute(input_tuples)
        print("LLR_2 binary ", LLR_2, [bins(int(i), 10) for i in LLR_2])
        
        LLR_2 = LLR_2 - LLR_interleaved - 2 * input_interleaved
        self.LLR_ext = self.deinterleave(LLR_2)
        # print("equal: ", LLR_1, [bins(int(i), 10) for i in LLR_1], " " , self.LLR_ext, [bins(int(i), 10) for i in self.LLR_ext])
        return self.early_exit(LLR_1, self.LLR_ext)

    def execute(self, vector):
        for i in range(self.max_iter):
            # print("iteration ", i)
            if self.iterate(vector, i):
                break
            if(i == 15):
                print("iteration finish", [int(s > 0) for s in self.LLR_ext])
        return self.LLR_ext
