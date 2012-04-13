patchagogy = @patchagogy ?= {}
patchagogy.units ?= {}

class patchagogy.Unit
  constructor: (@objectModel, @args) ->
    console.log 'making unit', @objectModel.get 'text'
    @connections = {}  # {outletIndex: [func, func, func...]}
    @inlets = []       # [inlet1Func, inlet2Func]
    @setup @objectModel, @args

  setConnections: (@connections) ->

  out: (i, arg) ->
    objectText = @objectModel.get 'text'
    # console.debug "out: #{objectText} from outlet #{i} with", arg
    ofuncs = @connections[i]
    if ofuncs
      for ofunc in ofuncs
        try
          ofunc arg
        catch error
          console.error objectText, \
            "error calling func connected to outlet #{i} with #{arg}:", \
            error
          throw error

  makeInlets: (numInlets, func) ->
    # convenience method to build @inlets from a function
    # that takes (inlet, arg)
    for index in _.range numInlets
      do (index) ->
        (arg) -> func index, arg

  stop: ->
