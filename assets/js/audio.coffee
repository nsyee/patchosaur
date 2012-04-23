patchosaur = @patchosaur ?= {}

SAMPLERATE   = 44100 # FIXME, can we get this from chrome or audiolet?
NUM_CHANNELS = 2
BLOCK_SIZE   = 64

patchosaur.audiolet = new Audiolet SAMPLERATE, NUM_CHANNELS, BLOCK_SIZE
