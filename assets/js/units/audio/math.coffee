class Cycle extends patchagogy.Unit
  # FIXME this doesn't work at all
  @names: ['muladd~']
  setup: (@objectModel, @args) ->
    # take num inlets from num args
    mul = @args[0] or 1
    add = @args[1] or 0
    @objectModel.set numInlets: 3
    @objectModel.set numOutlets: 1
    @inlets = [
        (->),
        ( (x) => @muladd.mul.setValue x),
        ( (x) => @muladd.add.setValue x)
    ]
    a = patchagogy.audiolet
    @muladd = new MulAdd a, mul, add
    mulNode = new PassThroughNode a, 1, 1
    addNode = new PassThroughNode a, 1, 1
    mulNode.connect @muladd, 0, 1
    mulNode.connect @muladd, 0, 2
    @audioletNodes = [@muladd, mulNode, addNode]

patchagogy.units.add Cycle
