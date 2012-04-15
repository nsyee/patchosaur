class ADC extends patchagogy.Unit
  @names: ['dac~', 'out~']
  setup: (@objectModel, @args) ->
    @objectModel.set numInlets: 2
    @objectModel.set numOutlets: 0
    @audioletGroup = patchagogy.audiolet.output

class DAC extends patchagogy.Unit
  @names: ['adc~', 'in~']
  setup: (@objectModel, @args) ->
    @objectModel.set numInlets: 0
    @objectModel.set numOutlets: 2
    @audioletGroup = patchagogy.audiolet.input

patchagogy.units.add ADC
patchagogy.units.add DAC
