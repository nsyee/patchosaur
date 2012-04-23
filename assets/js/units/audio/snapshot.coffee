class Snapshot extends patchosaur.Unit
  @names: ['snapshot~']
  # FIXME: document
  setup: (@objectModel) ->
    @objectModel.set numInlets: 2
    @objectModel.set numOutlets: 1
    a = patchosaur.audiolet
    @node = new PassThroughNode a, 1, 1
    @inlets = [undefined, =>
      # @node # get current value from node?
    ]
    @audioletInputNodes  = [@node, undefined]
    @audioletOutputNodes = [@node]

patchosaur.units.add Snapshot
