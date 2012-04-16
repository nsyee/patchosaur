class DAC extends patchagogy.Unit
  @names: ['dac~', 'out~']
  setup: (@objectModel, @args) ->
    @objectModel.set numInlets: 2
    @objectModel.set numOutlets: 0
    a = patchagogy.audiolet
    panL = new Pan a, 0
    panR = new Pan a, 1
    panL.connect a.output
    panR.connect a.output
    # analagous to inputs
    @audioletNodes = [panL, panR]

class ADC extends patchagogy.Unit
  @names: ['adc~', 'in~']
  setup: (@objectModel, @args) ->
    # FIXME: this doesn't really work, see DAC
    @objectModel.set numInlets: 0
    @objectModel.set numOutlets: 2
    @audioletGroup = patchagogy.audiolet.input

patchagogy.units.add ADC
patchagogy.units.add DAC
