#
# Bit Error Rate Performance Plot
#

#!/usr/bin/env python3

import argparse
import random
import numpy as np
import matplotlib.pyplot as plot
import copy
from turbo import TurboEncoder
from turbo import AWGN
from turbo import TurboDecoder
from turbo import SISODecoder

def convert(a, bit, bound):
    # a is a np.array
    # -----(-1)--|----|----|--(1)-----
    segments = 2**bit
    arr = copy.copy(a)
    segment_len = (bound - (-bound)) / (segments-1)
    arr[a > bound - segment_len * 0.5] = bound
    arr[a < -bound + segment_len * 0.5] = -bound
    for i in range(2, segments): # 2 to num of segments -1
        arr[(a > -bound + segment_len * (i-2 + 1/2)) & (a < -bound + segment_len * (i-1 + 1/2))] = -bound + segment_len * (i-1)
    return arr

def create_ber_plot(plot_params):
    block_size = plot_params["block_size"]
    #num_trials = plot_params["num_trials"]
    #bits_num   = plot_params["bits_num"]
    boundary   = plot_params["boundary"]

    snr_range = np.linspace(*plot_params["snr"])
    bit_range = np.linspace(*plot_params["bits_num"]).astype(np.int)

    interleaver = random.sample(range(0, block_size), block_size)
    encoder = TurboEncoder(interleaver)
    decoder = TurboDecoder(interleaver)

    coded_errors = np.zeros(len(snr_range))
    uncoded_errors = np.zeros(len(snr_range))

    truncated_errors = []
    for i in range(len(bit_range)):
        truncated_errors.append(np.zeros(len(snr_range)))

    for n in range(len(snr_range)):
        while()
            input_vector = np.random.randint(2, size=block_size)
            encoded_vector = encoder.execute(input_vector)

            channel = AWGN(snr_range[n])

            channel_vector = list(map(float, encoded_vector))
            channel_vector = channel.convert_to_symbols(channel_vector)
            uncoded_vector = list(map(float, input_vector))
            uncoded_vector = channel.convert_to_symbols(uncoded_vector)

            channel_vector = channel.execute(channel_vector)
            decoded_vector = decoder.execute(channel_vector)
            decoded_vector = [int(b > 0.0) for b in decoded_vector]

            for i in range(len(bit_range)):
                if (total errors less than 200):
                    truncated_vector = convert(channel_vector, bit_range[i], boundary)
                    truncated_vector = decoder.execute(truncated_vector)
                    truncated_vector = [int(b > 0.0) for b in truncated_vector]

            uncoded_vector = channel.execute(uncoded_vector)
            uncoded_vector = [int(b > 0.0) for b in uncoded_vector]

            coded_error_count = sum([x ^ y for x, y in zip(input_vector, decoded_vector)])
            truncated_error_count_0 = sum([x ^ y for x, y in zip(input_vector, decoded_vector_0)])
            truncated_error_count_1 = sum([x ^ y for x, y in zip(input_vector, decoded_vector_1)])
            truncated_error_count_2 = sum([x ^ y for x, y in zip(input_vector, decoded_vector_2)])
            truncated_error_count_3 = sum([x ^ y for x, y in zip(input_vector, decoded_vector_3)])
            truncated_error_count_4 = sum([x ^ y for x, y in zip(input_vector, decoded_vector_4)])
            truncated_error_count_5 = sum([x ^ y for x, y in zip(input_vector, decoded_vector_5)])
            uncoded_error_count = sum([x ^ y for x, y in zip(input_vector, uncoded_vector)])

            coded_errors[n] = coded_errors[n] + coded_error_count
            truncated_errors_0[n] = truncated_errors_0[n] + truncated_error_count_0
            truncated_errors_1[n] = truncated_errors_1[n] + truncated_error_count_1
            truncated_errors_2[n] = truncated_errors_2[n] + truncated_error_count_2
            truncated_errors_3[n] = truncated_errors_3[n] + truncated_error_count_3
            truncated_errors_4[n] = truncated_errors_4[n] + truncated_error_count_4
            truncated_errors_5[n] = truncated_errors_5[n] + truncated_error_count_5
            uncoded_errors[n] = uncoded_errors[n] + uncoded_error_count

        print("Finished {} trials for SNR = {:8.2f} dB ...".format(num_trials, snr_range[n]))

    coded_ber_values = coded_errors / (num_trials * block_size)
    truncated_ber_values_0 = truncated_errors_0 / (num_trials * block_size)
    truncated_ber_values_1 = truncated_errors_1 / (num_trials * block_size)
    truncated_ber_values_2 = truncated_errors_2 / (num_trials * block_size)
    truncated_ber_values_3 = truncated_errors_3 / (num_trials * block_size)
    truncated_ber_values_4 = truncated_errors_4 / (num_trials * block_size)
    truncated_ber_values_5 = truncated_errors_5 / (num_trials * block_size)
    uncoded_ber_values = uncoded_errors / (num_trials * block_size)
    # print(truncated_ber_values_0)
    # print(truncated_ber_values_1)
    # print(truncated_ber_values_2)
    # print(truncated_ber_values_3)
    # print(uncoded_ber_values)
    # print(coded_ber_values)

    plot.plot(snr_range, coded_ber_values, "r.-", label="Coded BPSK")
    plot.plot(snr_range, truncated_ber_values_0, "g*-", label=f"Truncated w/ {bit_range[0]} bits and {boundary} bound BPSK")
    plot.plot(snr_range, truncated_ber_values_1, "c*-", label=f"Truncated w/ {bit_range[1]} bits and {boundary} bound BPSK")
    plot.plot(snr_range, truncated_ber_values_2, "m*-", label=f"Truncated w/ {bit_range[2]} bits and {boundary} bound BPSK")
    plot.plot(snr_range, truncated_ber_values_3, "y*-", label=f"Truncated w/ {bit_range[3]} bits and {boundary} bound BPSK")
    plot.plot(snr_range, truncated_ber_values_4, "k*-", label=f"Truncated w/ {bit_range[4]} bits and {boundary} bound BPSK")
    plot.plot(snr_range, truncated_ber_values_5, "y^-", label=f"Truncated w/ {bit_range[5]} bits and {boundary} bound BPSK")
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
        default=1000000,
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
        "bits_num": [2,7,6],
        "boundary": 8
    }
    create_ber_plot(plot_params)
