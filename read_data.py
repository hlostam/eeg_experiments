import time
import argparse

from muselsl import stream, list_muses

MUSE_BOARD_ID = 22
MUSE_MAC_ADDRESS = '00:55:DA:B7:B0:5C'
MUSE_NAME = 'Muse-B05C'

DEFAULT_COM_PORT = '/dev/tty.usbmodem11'
DEFAULT_TIMEOUT = 5

def read_data_brainflow(args):
    from brainflow.board_shim import BoardShim, BrainFlowInputParams
    from brainflow.data_filter import DataFilter, FilterTypes, AggOperations
    BoardShim.enable_dev_board_logger()

    params = BrainFlowInputParams()
    params.serial_port = args.serial_port
    params.timeout = args.timeout
    board = BoardShim(MUSE_BOARD_ID, params)
    board.prepare_session()

    board.start_stream()
    # board.start_stream(45000, args.streamer_params)
    time.sleep(10)
    
    data = board.get_board_data()
    board.stop_stream()
    board.release_session()
    
    print("Finished loading data")
    print(data)

def read_data_lsl(args):
    muses = list_muses()
    stream(muses[0]['address'])

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--serial-port', type=str, help='serial port', required=False, default=DEFAULT_COM_PORT)
    parser.add_argument('--timeout', type=int, help='timeout for device discovery or connection', required=False,
                        default=DEFAULT_TIMEOUT)
    parser.add_argument('--streamer-params', type=str, help='streamer params', required=False, default='')
    args = parser.parse_args()

    from muselsl import record
    print('Recording ...')
    record(5)
    # Note: Recording is synchronous, so code here will not execute until the stream has been closed
    print('Recording has ended')

    
if __name__ == "__main__":
    main()