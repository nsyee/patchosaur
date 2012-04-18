class Cycle extends patchagogy.Unit
  @names: ['cycle~']
  setup: (@objectModel, @args) ->
    # take num inlets from num args
    arg = @args[0]
    if not _.isNumber arg
      arg = 440
    @freq = arg
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    @inlets = [(x)=>@sine.frequency.setValue x] # FIXME
    @sine = new Sine patchagogy.audiolet, arg
    @audioletInputNodes = [@sine]
    @audioletOutputNodes = [@sine]

patchagogy.units.add Cycle
