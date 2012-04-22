patchosaur = @patchosaur ?= {}

class patchosaur.Unit
  constructor: (@objectModel) ->
    console.log 'making unit', @objectModel.get 'text'
    @connections = {}  # {outletIndex: [func, func, func...]}
    @inlets = []       # [inlet1Func, inlet2Func]
    @setup @objectModel

  setConnections: (@connections) ->

  out: (i, arg) ->
    # console.debug "out: #{objectText} from outlet #{i} with", arg
    ofuncs = @connections[i]
    if ofuncs
      for ofunc in ofuncs
        try
          ofunc arg
        catch error
          objectText = @objectModel.get 'text'
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

class patchosaur.Units
  constructor: -> @units = {}

  add: (UnitClass) ->
    for name in UnitClass.names
      if @units[name]?
        console.error "unit class already defined:", name, UnitClass
      else
        @units[name] = UnitClass

  get: (name) ->
    @units[name] or console.log 'no unit class by name:', name

patchosaur.units = new patchosaur.Units
