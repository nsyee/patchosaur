{EventEmitter} = require 'events'
_ = require 'underscore'

VIRTUAL_PORT = 'patchosaur'

MIDI_COMMANDS =
  0x90: 'noteOn'
  0x80: 'noteOff'
  0xA0: 'aftertouch'
  0xB0: 'cc'
  0xC0: 'patchChange'
  0xD0: 'channelPressure'
  0xE0: 'pitchBend'
  0xF0: 'nonMusical'

# FIXME: make logging class
console.log 'loading midi...'

# https://github.com/justinlatimer/node-midi
midi = require 'midi'

inputs = [] # actual midi inputs
input  = new EventEmitter # aggregate

# write to virtual output
# on lion, doesn't show up in audio midi
# setup, but does in everything else
output = new midi.output
output.openVirtualPort VIRTUAL_PORT

# listen to everything, including own virtual
virtualInput = new midi.input
virtualInput.openVirtualPort VIRTUAL_PORT
inputs.push virtualInput

convertNoteOffs = (formattedMessage) ->
  # convert note offs to note ons with 0 vel
  if formattedMessage.type == 'noteOff'
    formattedMessage.type = 'noteOn'
    formattedMessage.velocity = 0
  formattedMessage

formatMessage = (deltaTime, message) ->
  midiEvent =
    type: MIDI_COMMANDS[message[0]]
    note: message[1]
    velocity: message[2]
    deltaTime: deltaTime
  convertNoteOffs midiEvent

for i in _.range do virtualInput.getPortCount
  inPort = new midi.input
  inPort.openPort i
  console.log 'listening to midi input port', inPort.getPortName i
  inPort.on 'message', (deltaTime, message) ->
    input.emit 'message', formatMessage deltaTime, message

cleanUp = ->
  console.log 'cleaning up midi...'
  for port in _.flatten [inputs, output]
    console.log 'closing port', do port.getPortName
    do port.closePort

# necessary?
process.on 'SIGINT', ->
  do cleanUp
  process.exit()

console.log 'midi ready...'

module.exports =
  input: input
  output: output
