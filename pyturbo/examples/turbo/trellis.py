#
# Trellis Object
#

import itertools
import numpy as np

DATA_BITS = 12

def overflow(num, data_size):
    if(num > 2**(data_size-1)-1):
        return 2**(data_size-1)-1
    elif(num < -2**(data_size-1)):
        return -2**(data_size-1)
    else:
        return num
        
class Trellis:
    def butterfly(self, path_metrics, branch_metrics):
        # result = [path + branch for path, branch in zip(path_metrics, branch_metrics)]
        result = [overflow(path + branch, self.data_size) for path, branch in zip(path_metrics, branch_metrics)]
        return np.max(result)

    def __init__(self):
        self.transition_matrix = np.array(
                                  [[(-1, -1), None, (1, 1), None],
                                  [(1, -1), None, (-1, 1), None],
                                  [None, (-1, -1), None, (1, 1)],
                                  [None, (1, -1), None, (-1, 1)]])

        self.past_states = [(0, 1), (2, 3), (0, 1), (2, 3)]
        self.future_states = [(0, 2), (0, 2), (1, 3), (1, 3)]
        self.data_size = DATA_BITS
        all_transitions = list(itertools.product([0, 1, 2, 3], repeat=2))
        self.possible_transitions = [t for t in all_transitions if self.transition_matrix[t] is not None]

    def transition_to_symbols(self, state, next_state):
        return self.transition_matrix[state, next_state]
