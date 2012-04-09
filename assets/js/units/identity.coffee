class Identity extends patchagogy.Unit
  setup: (@objectModel, @args) ->
    console.log 'making identity unit', @
    [numInlets, rest...] = @args
    numInlets = parseInt(numInlets)
    numInlets = 2 if not _.isFinite numInlets
    @objectModel.set numInlets: numInlets
    @objectModel.set numOutlets: numInlets + 1
    # make inlets from @call
    @inlets = @makeInlets numInlets, @call

  call: (i, arg) =>
    @out i, arg

patchagogy.units['identity'] = Identity

