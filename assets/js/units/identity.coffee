class Identity extends patchagogy.Unit
  constructor: (@objectModel, @args) ->
    [numInlets, rest...] = @args
    numInlets = parseInt(numInlets)
    numInlets = 2 if not _.isFinite numInlets
    @objectModel.set numInlets: numInlets
    @objectModel.set numOutlets: 4

  call: (i, args...) ->
    @out i, arg

patchagogy.units['identity'] = Identity

