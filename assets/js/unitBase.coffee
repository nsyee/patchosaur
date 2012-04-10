patchagogy = @patchagogy ?= {}
patchagogy.units ?= {}

class patchagogy.Unit
  constructor: (@objectModel, @args) ->
    console.log 'making unit', @objectModel.get 'text'
    @connections = {}  # {outletIndex: [func, array]}
    @inlets = []       # [inlet1Func, inlet2Func]
    @setup @objectModel, @args

  setConnections: (@connections) ->

  out: (i, arg) ->
    console.debug @objectModel.get('text'), 'out:', i, arg
    ofuncs = @connections[i]
    if ofuncs
      for ofunc in ofuncs
        try
          ofunc arg
        catch error
          console.error @objectModel.get('text'), \
            "error calling func connected to outlet #{i} with #{arg}:", \
            error

  makeInlets: (numInlets, func) ->
    console.log 'calling makeInlets'
    # convenience method to build @inlets from a function
    # that takes (inlet, arg)
    for index in _.range numInlets
      (arg) -> func index, arg

  stop: ->




