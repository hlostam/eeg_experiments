# eeg_experiments

## MuseLsl (working)
0. Turn on the MUSE and insert the BLE Dongle
1. Start the stream ```muselsl stream```
2. 


## Brainflow - Setting up the connection

1. Finding out the COM port for the dongle:
```ls /dev/tty.*```
    - It should be this one: Dongle port: /dev/tty.usbmodem11
2. ```python read_data.py --timeout 15 --serial-port /dev/tty.usbmodem11```
    - Output (hopefully):
    ```
    Board object created 22
    Library is loaded
    ```

