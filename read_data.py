import time
import argparse

from brainflow.board_shim import BoardShim, BrainFlowInputParams
from brainflow.data_filter import DataFilter, FilterTypes, AggOperations

MUSE_BOARD_ID = 22
DEFAULT_COM_PORT = '/dev/tty.usbmodem11'
DEFAULT_TIMEOUT = 5

def main():
    BoardShim.enable_dev_board_logger()

    parser = argparse.ArgumentParser()
    parser.add_argument('--serial-port', type=str, help='serial port', required=False, default=DEFAULT_COM_PORT)
    parser.add_argument('--timeout', type=int, help='timeout for device discovery or connection', required=False,
                        default=DEFAULT_TIMEOUT)
    parser.add_argument('--streamer-params', type=str, help='streamer params', required=False, default='')
    args = parser.parse_args()

    params = BrainFlowInputParams()
    params.serial_port = args.serial_port
    params.timeout = args.timeout
    print(args)
    print('hello there')
    board = BoardShim(MUSE_BOARD_ID, params)
    print('hello here')
    board.prepare_session()

    board.start_stream()
    # board.start_stream(45000, args.streamer_params)
    print('here')
    time.sleep(10)
    print('after sleep')

    data = board.get_board_data()
    board.stop_stream()
    board.release_session()
    
    print("Finished loading data")
    print(data)

if __name__ == "__main__":
    main()
