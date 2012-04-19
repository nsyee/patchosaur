class Identity extends patchosaur.Unit
  @names: ['identity']
  setup: (@objectModel, @args) ->
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    # make inlets from @call
    @inlets = @makeInlets 1, @call

  call: (i, arg) =>
    @out i, arg

patchosaur.units.add Identity
