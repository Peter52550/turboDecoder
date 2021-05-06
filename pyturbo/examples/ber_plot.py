#
# Bit Error Rate Performance Plot
#

#!/usr/bin/env python3

import argparse
import random
import numpy as np
import matplotlib.pyplot as plot

from turbo import TurboEncoder
from turbo import AWGN
from turbo import TurboDecoder
from turbo import SISODecoder

def convert(a, bit, bound):
    # a is a np.array
    # -----(-1)--|----|----|--(1)-----
    segments = 2**bit
    segment_len = (bound - (-bound)) / (segments-1)
    a[a > bound - segment_len * 0.5] = bound
    a[a < -bound + segment_len * 0.5] = -bound
    for i in range(2, segments): # 2 to num of segments -1
        a[(a > -bound + segment_len * (i-2 + 1/2)) & (a < -bound + segment_len * (i-1 + 1/2))] = -bound + segment_len * (i-1)

def create_ber_plot(plot_params):
    block_size = plot_params["block_size"]
    num_trials = plot_params["num_trials"]
    bits_num   = plot_params["bits_num"]
    boundary   = plot_params["boundary"]

    snr_range = np.linspace(*plot_params["snr"])

    interleaver = random.sample(range(0, block_size), block_size)
    encoder = TurboEncoder(interleaver)
    decoder = TurboDecoder(interleaver)

    coded_errors = np.zeros(len(snr_range))
    truncated_errors = np.zeros(len(snr_range))
    uncoded_errors = np.zeros(len(snr_range))

    for n in range(len(snr_range)):
        for _ in range(num_trials):
            input_vector = np.random.randint(2, size=block_size)
            #print(f"input: {input_vector[:10]}")
            encoded_vector = encoder.execute(input_vector)
            #print(f"after encode: {encoded_vector[:10]}")
            channel = AWGN(snr_range[n])

            channel_vector = list(map(float, encoded_vector))
            channel_vector = channel.convert_to_symbols(channel_vector)
            uncoded_vector = list(map(float, input_vector))
            uncoded_vector = channel.convert_to_symbols(uncoded_vector)

            channel_vector = channel.execute(channel_vector)
            #print(f"encoded after AWGN: {channel_vector[:10]}")
            decoded_vector = decoder.execute(channel_vector)
            decoder.reset()
            #print(f"decoded pre-decision: {decoded_vector[:10]}")
            convert(channel_vector, bits_num, boundary) 
            #print(f"encoded after truncate: {channel_vector}")
            decoded_vector_2 = decoder.execute(channel_vector)
            #print(f"truncated pre-decision: {decoded_vector_2}")
            decoded_vector = [int(b > 0.0) for b in decoded_vector]
            decoded_vector_2 = [int(b > 0.0) for b in decoded_vector_2]
            #print(f"decoded post-decision: {decoded_vector}")
            #print(f"truncated post-decision: {decoded_vector_2}")

            uncoded_vector = channel.execute(uncoded_vector)
            #print(f"input after AWGN: {uncoded_vector}")
            convert(uncoded_vector, bits_num, boundary)
            #print(f"input after truncate: {uncoded_vector}")
            uncoded_vector = [int(b > 0.0) for b in uncoded_vector]
            #print(f"input post-decision: {uncoded_vector}")
            decoder.reset()

            coded_error_count = sum([x ^ y for x, y in zip(input_vector, decoded_vector)])
            truncated_error_count = sum([x ^ y for x, y in zip(input_vector, decoded_vector_2)])
            uncoded_error_count = sum([x ^ y for x, y in zip(input_vector, uncoded_vector)])

            coded_errors[n] = coded_errors[n] + coded_error_count
            truncated_errors[n] = truncated_errors[n] + truncated_error_count
            uncoded_errors[n] = uncoded_errors[n] + uncoded_error_count

        print("Finished {} trials for SNR = {:8.2f} dB ...".format(num_trials, snr_range[n]))

    coded_ber_values = coded_errors / (num_trials * block_size)
    truncated_ber_values = truncated_errors / (num_trials * block_size)
    uncoded_ber_values = uncoded_errors / (num_trials * block_size)

    plot.plot(snr_range, coded_ber_values, "r.-", label="Coded BPSK")
    plot.plot(snr_range, truncated_ber_values, "y*-", label=f"Truncated w/ {bits_num} bits and {boundary} bound BPSK")
    plot.plot(snr_range, uncoded_ber_values, "bo-", label="Uncoded BPSK")
    plot.yscale("log")
    plot.title("Turbo Codes Performance for R=1/3, Block={}, Trials={}".format(block_size, num_trials))
    plot.xlabel("SNR [dB]")
    plot.ylabel("Bit Error Rate (BER)")
    plot.grid(b=True, which="major", linestyle="-")
    plot.grid(b=True, which="minor", linestyle="--")
    plot.legend()
    plot.show()


def options():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-s", "--snr", nargs=3, type=float,
        default=[-10.0, 20.0, 20],
        help="SNR range [dB] in an AWGN channel"
    )
    parser.add_argument(
        "--block-size", type=int,
        default=100,
        help="Block size (size of interleaver)"
    )
    parser.add_argument(
        "--num-trials", type=int,
        default=50,
        help="Number of trials to run BER simulation"
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = options()
    plot_params = {
        "snr": args.snr,
        "block_size": args.block_size,
        "num_trials": args.num_trials,
        "bits_num": 4,
        "boundary": 1
    }
    print(type(args.snr), args.snr)
    create_ber_plot(plot_params)
