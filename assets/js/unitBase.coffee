patchosaur = @patchosaur ?= {}

class patchosaur.Unit
  constructor: (@objectModel) ->
    text = @objectModel.get 'text'
    console.log 'making unit', text
    @connections = {}  # {outletIndex: [func, func, func...]}
    @inlets = []       # [inlet1Func, inlet2Func]
    try
      @setup @objectModel
    catch error
      console.error "error setting up", text, error
      @objectModel.set error: error

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
    if not UnitClass.names or _.isEmpty UnitClass.names
      console.error "no names on UnitClass:", UnitClass
    for name in UnitClass.names
      if @units[name]?
        console.error "unit class already defined:", name, UnitClass
      else
        @units[name] = UnitClass

  get: (name) ->
    @units[name] or console.log 'no unit class by name:', name

patchosaur.units = new patchosaur.Units
