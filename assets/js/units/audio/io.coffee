# FIXME: add ADC

class DAC extends patchosaur.Unit
  @names: ['dac~', 'out~']
  setup: (@objectModel) ->
    # FIXME: get numOutlets
    @objectModel.set numInlets: 2
    @objectModel.set numOutlets: 0
    @a = patchosaur.audiolet
    @panL = new Pan @a, 0
    @panR = new Pan @a, 1
    @panL.connect @a.output
    @panR.connect @a.output
    @audioletInputNodes = [@panL, @panR]

  stop: ->
    # FIXME: why is this necessary?
    for node in [@panL, @panR]
      node.disconnect @a.output

patchosaur.units.add DAC
