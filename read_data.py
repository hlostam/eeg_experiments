import time
import argparse

from brainflow.board_shim import BoardShim, BrainFlowInputParams
from brainflow.data_filter import DataFilter, FilterTypes, AggOperations

MUSE_BOARD_ID = 22

def main():
    BoardShim.enable_dev_board_logger()

    parser = argparse.ArgumentParser()
    parser.add_argument('--serial-port', type=str, help='serial port', required=False, default='')
    parser.add_argument('--timeout', type=int, help='timeout for device discovery or connection', required=False,
                        default=0)
    args = parser.parse_args()

    params = BrainFlowInputParams()
    params.serial_port = args.serial_port
    params.timeout = args.timeout
    
    board = BoardShim(MUSE_BOARD_ID, params)
    board.start_stream()

    time.sleep(2)
    data = board.get_board_data()
    board.release_session()
    
    print("Finished loading data")
    print(data)

if __name__ == "__main__":
    main()
