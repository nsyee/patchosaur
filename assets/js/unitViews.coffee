#= require unitBase

# FIXME: put this directly on models? that seems like a bad idea too
patchosaur = @patchosaur = @patchosaur or {}

DEFAULT_UNIT = 'identity'

patchosaur.UnitGraphView = Backbone.View.extend
  initialize: () ->
    @objects = @options.objects

    @objects.bind 'remove', (object) =>
      object.get('unit').stop()

    @objects.bind 'add change:text', (o) =>
      o.get('unit')?.stop()
      @disconnectPreviousAudioletUnits o
      UnitClass = patchosaur.units.get o.get 'unitClassName'
      if not UnitClass
        # FIXME: just don't make it?
        console.warn "no unit class found for #{o.get 'unitClassName'}, using #{DEFAULT_UNIT}"
        UnitClass = patchosaur.units.get DEFAULT_UNIT
      unit = new UnitClass o, o.get 'unitArgs'
      console.log 'unit', unit
      o.set unit: unit
      @makeConnectionsFrom o

    @objects.bind 'change:connections', (object) =>
      @disconnectPreviousAudioletUnits object
      @makeConnectionsFrom object

  audioletDisconnect: (connection) ->
    [fromID, outlet, toID, inlet] = connection
    fromUnit = @objects.get(fromID)?.get('unit')
    toUnit = @objects.get(toID)?.get('unit')
    if toUnit?.audioletInputNodes?
      fromUnit?.audioletOutputNodes?[outlet].disconnect toUnit.audioletInputNodes[inlet]

  disconnectPreviousAudioletUnits: (object) ->
    # disconnect audiolet units to and from this object
    prevConns = object.getPreviousConnections()
    for connection in prevConns
      @audioletDisconnect connection
    affected = @objects.connectedFrom object
    _.each affected, (object) =>
      connections = object.get 'connections'
      for connection in connections
        @audioletDisconnect connection

  makeConnectionsFrom: (object) ->
    # redo connections on objects connected to this one,
    # including this one
    affected = @objects.connectedFrom object
    _.each affected, (object) =>
      @makeConnections object

  makeConnections: (object) ->
    # FIXME: put method to get inlet funcs on model?
    connections = object.getConnections()
    fromUnit = object.get 'unit'
    return if not fromUnit
    console.log 'redoing unit connections on', object.get 'text'
    unitConnections = {}
    for connection in connections
      [fromID, outlet, toID, inlet] = connection
      toUnit = @objects.get(toID)?.get('unit')
      toFunc = toUnit?.inlets[inlet]
      # connect audiolet groups
      if toUnit?.audioletInputNodes?
        fromUnit?.audioletOutputNodes?[outlet].connect toUnit.audioletInputNodes[inlet]
      # make make normal connections
      if toFunc
        unitConnections[outlet] or= []
        unitConnections[outlet].push toFunc
      else
        console.warn "no inlet func here, we must be loading a patch", object, @objects.get toID
    fromUnit.setConnections unitConnections
