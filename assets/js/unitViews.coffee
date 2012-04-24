patchosaur = @patchosaur ?= {}

DEFAULT_UNIT = 'null'

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
        message = "no unit class found for #{o.get 'unitClassName'}, using #{DEFAULT_UNIT}"
        console.warn message
        UnitClass = patchosaur.units.get DEFAULT_UNIT
        if not o.get 'error'
          o.set 'error', message
      unit = new UnitClass o
      o.set unit: unit
      @makeConnectionsFrom o

    @objects.bind 'change:connections', (object) =>
      @disconnectPreviousAudioletUnits object
      @makeConnectionsFrom object

  audioletDisconnect: (connection, changedObject) ->
    # if changedObject was removed, collection.get
    # won't work, FIXME: this is an ugly hack
    [fromID, outlet, toID, inlet] = connection
    # get units
    if changedObject and fromID == changedObject.id
      fromUnit = changedObject.get 'unit'
    else
      fromUnit = @objects.get(fromID)?.get('unit')
    if changedObject and toID == changedObject.id
      toUnit = changedObject.get 'unit'
    else
      toUnit = @objects.get(toID)?.get('unit')
    if toUnit?.audioletInputNodes?
      # FIXME: no longer exists when removing object, though disconnect
      # events fire first 
      # console.log @objects.get(fromID)
      fromUnit?.audioletOutputNodes?[outlet].disconnect toUnit.audioletInputNodes[inlet]

  disconnectPreviousAudioletUnits: (object) ->
    # disconnect audiolet units to and from this object
    prevConns = object.getPreviousConnections()
    for connection in prevConns
      @audioletDisconnect connection, object
    affected = @objects.connectedFrom object
    _.each affected, (object) =>
      connections = object.get 'connections'
      for connection in connections
        @audioletDisconnect connection, object

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
    fromUnit.setConnections unitConnections
