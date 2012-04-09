class Identity extends patchagogy.Unit
  constructor: ->
  call: (i, args...) ->
    @out i, arg

patchagogy.units['identity'] = Identity

