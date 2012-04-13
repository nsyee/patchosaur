{EventEmitter} = require 'events'

VIRTUAL_PORT = 'Patchagogy'

# FIXME: make logging class
console.log 'loading midi...'

# https://github.com/justinlatimer/node-midi
midi = require 'midi'

output = new midi.output
output.openVirtualPort VIRTUAL_PORT
# FIXME? omni would be nicer
input = new midi.input
input.openVirtualPort VIRTUAL_PORT

module.exports =
  input: input
  output: output

cleanUp = ->
  console.log 'cleaning up midi...'
  do output.closePort
  do input.closePort

# necessary?
process.on 'SIGINT', ->
  do cleanUp
  process.exit()

console.log 'midi ready...'
