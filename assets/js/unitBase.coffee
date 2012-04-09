patchagogy = @patchagogy = @patchagogy or {}
patchagogy.units ?= {}

# FIXME: do you want each inlet to have a func, or one func for all? both?
# both.
# nah, maybe just inlet and outlet calls
#
# are these, models, views, what's what.

class patchagogy.Unit
  constructor: (@objectModel, @args) ->
    @connections = {}  # {outletIndex: [func, array]}
    @inlets = []       # [inlet1Func, inlet2Func]
    @setup @objectModel, @args

  setConnections: (@connections) ->

  out: (i, arg) ->
    for ofunc in @connections[i]
      ofunc arg
  
  makeInlets: (numInlets, func) ->
    # convenience method to build @inlets from a function
    # that takes (inlet, arg)
    @inlets = for index in _.range numInlets
      (arg) -> do func index, arg




