from eegnb.devices.eeg import EEG

# define the name for the board you are using and call the EEG object
eeg = EEG(device='muse2')

# start the stream
eeg.start()
