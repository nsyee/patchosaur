class Cycle extends patchagogy.Unit
  # FIXME this doesn't work at all
  @names: ['muladd~']
  setup: (@objectModel, @args) ->
    # take num inlets from num args
    @mul = @args[0] or 1
    @add = @args[0] or 0
    @objectModel.set numInlets: 3
    @objectModel.set numOutlets: 1
    @inlets = [
        (->),
        ( (x) => @muladd.mul.setValue x),
        ( (x) => @muladd.add.setValue x)
    ]
    @muladd = new MulAdd patchagogy.audiolet, @mul, @add
    @audioletNodes = [@muladd.inputs[0], @muladd.inputs[1], @muladd.inputs[2]]

patchagogy.units.add Cycle
