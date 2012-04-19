class DAC extends patchosaur.Unit
  @names: ['dac~', 'out~']
  setup: (@objectModel, @args) ->
    @objectModel.set numInlets: 2
    @objectModel.set numOutlets: 0
    a = patchosaur.audiolet
    panL = new Pan a, 0
    panR = new Pan a, 1
    panL.connect a.output
    panR.connect a.output
    # analagous to inputs
    @audioletInputNodes = [panL, panR]

class ADC extends patchosaur.Unit
  @names: ['adc~', 'in~']
  setup: (@objectModel, @args) ->
    # FIXME: this doesn't really work, see DAC
    @objectModel.set numInlets: 0
    @objectModel.set numOutlets: 2
    @audioletGroup = patchosaur.audiolet.input

patchosaur.units.add ADC
patchosaur.units.add DAC
