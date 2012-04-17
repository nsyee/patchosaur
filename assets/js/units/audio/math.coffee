class Cycle extends patchagogy.Unit
  # FIXME this doesn't work at all
  @names: ['muladd~']
  setup: (@objectModel, @args) ->
    # take num inlets from num args
    @mul = 1 # fixme: take args, right now [0] is m from muladd
    @add = 0
    @objectModel.set numInlets: 3
    @objectModel.set numOutlets: 1
    @inlets = [
        (->),
        ( (x) => @muladd.mul.setValue x),
        ( (x) => @muladd.add.setValue x)
    ]
    a = patchagogy.audiolet
    @muladd = new MulAdd a, @mul, @add
    # these are audiolet inputs, not nodes
    node1 = new PassThroughNode a, 1, 1
    node2 = new PassThroughNode a, 1, 1
    node3 = new PassThroughNode a, 1, 1
    node1.connect @muladd, 0, 0
    node2.connect @muladd, 0, 1
    node3.connect @muladd, 0, 2
    @audioletNodes = [node1, node2, node3]

patchagogy.units.add Cycle
