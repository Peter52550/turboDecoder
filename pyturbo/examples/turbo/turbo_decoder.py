#
# Turbo Decoder
#

import numpy as np

from .siso_decoder import SISODecoder

def overflow(num, data_size):
    if(num > 2**(data_size-1)-1):
        return 2**(data_size-1)-1
    elif(num < -2**(data_size-1)):
        return -2**(data_size-1)
    else:
        return num

def bins(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)
class TurboDecoder:
    @staticmethod
    def demultiplex(a, b, extrinsic):
        return list(zip(a, b, extrinsic))

    @staticmethod
    def early_exit(LLR, LLR_ext):
        LLR = [int(s >= 0) for s in LLR[:-2]]
        LLR_ext = [int(s >= 0) for s in LLR_ext[:-2]]
        #if(LLR == LLR_ext):
        #    print("EARLY EXIT!:", [int(s >= 0) for s in LLR])
        return LLR == LLR_ext

    def __init__(self, interleaver, tail_bits=2, max_iter=10):
        self.interleaver = interleaver
        self.block_size = len(self.interleaver)
        self.tail_bits = tail_bits
        self.max_iter = max_iter

        self.decoders = 2 * [SISODecoder(self.block_size + tail_bits)]
        self.count = 1
        self.data_size = self.decoders[0].data_size
        self.debug = self.decoders[0].debug
        self.print_siso = False
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
        #print("\n\n=====================================")
        #print()
        #print(f"\tITERATION {i}")
        #print()
        #print("=====================================")
        #print()
        #print("vector[::3]", vector[::3], [bins(int(i), 4) for i in vector[::3]])
        #print("vector[1::3]", vector[1::3], [bins(int(i), 4) for i in vector[1::3]])
        #print("self.LLR_ext", self.LLR_ext, [bins(int(i), 10) for i in self.LLR_ext])
        #print()
        LLR_1 = self.decoders[0].execute(input_tuples, i)

        if self.debug:
            print(f"LLR_1: {LLR_1}")
        if self.debug or self.print_siso:
            print(str(self.count).rjust(3), end=" ")
            self.count += 1
            for j in [bins(int(i), self.data_size) for i in LLR_1]:
                print(j, end="")
            print()

        #LLR_1 = LLR_1 - self.LLR_ext - 2 * vector[::3]
        LLR_1_temp_1 = LLR_1 - self.LLR_ext
        LLR_1_temp_1 = np.array([overflow(a, self.data_size) for a in LLR_1_temp_1])
        LLR_1_temp_2 = LLR_1_temp_1 - vector[::3]
        LLR_1_temp_2 = np.array([overflow(a, self.data_size) for a in LLR_1_temp_2])
        LLR_1_temp_3 = LLR_1_temp_2 - vector[::3]
        LLR_1 = np.array([overflow(a, self.data_size) for a in LLR_1_temp_3])

        LLR_interleaved = self.interleave(LLR_1)
        input_interleaved = self.interleave(vector[::3])
        
        #print()
        #print("input_interleaved", input_interleaved, [bins(int(i), 4) for i in input_interleaved])
        #print("vector[2::3]", vector[2::3], [bins(int(i), 4) for i in vector[2::3]])
        if self.debug:
            print("LLR_interleaved", LLR_interleaved)
        #print()
        input_tuples = self.demultiplex(input_interleaved, vector[2::3], LLR_interleaved)

        LLR_2 = self.decoders[1].execute(input_tuples)
        if self.debug:
            print(f"LLR_2: {LLR_2}")
        if self.debug or self.print_siso:
            print(str(self.count).rjust(3), end=" ")
            self.count += 1
            for j in [bins(int(i), self.data_size) for i in LLR_2]:
                print(j, end="")
            print()

        #LLR_2 = LLR_2 - LLR_interleaved - 2 * input_interleaved
        LLR_2_temp_1 = LLR_2 - LLR_interleaved 
        LLR_2_temp_1 = np.array([overflow(a, self.data_size) for a in LLR_2_temp_1])
        LLR_2_temp_2 = LLR_2_temp_1 - input_interleaved
        LLR_2_temp_2 = np.array([overflow(a, self.data_size) for a in LLR_2_temp_2])
        LLR_2_temp_3 = LLR_2_temp_2 - input_interleaved
        LLR_2 = np.array([overflow(a, self.data_size) for a in LLR_2_temp_3])

        self.LLR_ext = self.deinterleave(LLR_2)
        if self.debug:
            print("LLR_ext", self.LLR_ext)
            print("equal: \n", [int(s >= 0) for s in LLR_1[:-2]], " " , [int(s >= 0) for s in self.LLR_ext[:-2]])
        return self.early_exit(LLR_1, self.LLR_ext)

    def execute(self, vector):
        for i in range(self.max_iter):
            # print("iteration ", i)
            if self.iterate(vector, i):
                break
            #if(i == 15):
            #    print("iteration finish", [int(s >= 0) for s in self.LLR_ext])
        return self.LLR_ext
