class DAC extends patchagogy.Unit
  @names: ['dac~', 'out~']
  setup: (@objectModel, @args) ->
    @objectModel.set numInlets: 2
    @objectModel.set numOutlets: 0
    a = patchagogy.audiolet
    group = new AudioletGroup a, 2, 2
    panL = new Pan a, 0
    panR = new Pan a, 1
    group.inputs[0].connect panL
    group.inputs[1].connect panR
    panL.connect a.output
    panR.connect a.output
    @audioletGroup = group

class ADC extends patchagogy.Unit
  @names: ['adc~', 'in~']
  setup: (@objectModel, @args) ->
    # FIXME: this doesn't really work, see DAC
    @objectModel.set numInlets: 0
    @objectModel.set numOutlets: 2
    @audioletGroup = patchagogy.audiolet.input

patchagogy.units.add ADC
patchagogy.units.add DAC
