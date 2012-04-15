class Cycle extends patchagogy.Unit
  @names: ['cycle~']
  setup: (@objectModel, @args) ->
    # take num inlets from num args
    @freq = @args[0] or 440
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    @inlets = [(x)=>@sine.frequency.setValue x] # FIXME
    @audioletGroup = new Sine(patchagogy.audiolet, 440)

patchagogy.units.add Cycle
