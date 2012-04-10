class Identity extends patchagogy.Unit
  setup: (@objectModel, @args) ->
    console.log 'making identity unit', @
    [numInlets, rest...] = @args
    numInlets = parseInt(numInlets)
    numInlets = 1 if not _.isFinite numInlets
    @objectModel.set numInlets: numInlets
    @objectModel.set numOutlets: numInlets
    # make inlets from @call
    @inlets = @makeInlets numInlets, @call

  call: (i, arg) =>
    @out i, arg

patchagogy.units['identity'] = Identity

