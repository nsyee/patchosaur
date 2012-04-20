#= require unitBase

# FIXME: put this directly on models? that seems like a bad idea too
patchosaur = @patchosaur = @patchosaur or {}

DEFAULT_UNIT = 'identity'

patchosaur.UnitGraphView = Backbone.View.extend
  initialize: () ->
    # see uiviews for knowing when to redo connections
    @objects = @options.objects

    @objects.bind 'remove', (object) =>
      object.get('unit').stop()

    @objects.bind 'add change:text', (o) =>
      # FIXME: audio units need to be disconnected before you make the new unit
      # when you are changing text. split up redoConnections and call remove prev before to fix the bug
      o.get('unit')?.stop()
      UnitClass = patchosaur.units.get o.get 'unitClassName'
      if not UnitClass
        # FIXME: just don't make it?
        console.warn "no unit class found for #{o.get 'unitClassName'}, using #{DEFAULT_UNIT}"
        UnitClass = patchosaur.units.get DEFAULT_UNIT
      unit = new UnitClass o, o.get 'unitArgs'
      console.log 'unit', unit
      o.set unit: unit
      @redoConnections o

    @objects.bind 'change:connections', (object) =>
      @redoConnections object

  redoConnections: (changedObject) ->
    prevConns = changedObject.getPreviousConnections()
    affected = @objects.connectedFrom changedObject
    _.each affected, (object) =>
      # remove all previous audiolet connections
      # FIXME: rethink this
      for connection in prevConns
        [fromID, outlet, toID, inlet] = connection
        fromUnit = object.get 'unit'
        console.log 'fromUnit', object, fromUnit, JSON.stringify connection
        # for some reason, muladd doesn't have a unit yet.
        # that's when you're trying to connect to it from cycle though
        # only doesn't get connected on patch load
        toUnit = @objects.get(toID)?.get('unit')
        if toUnit?.audioletInputNodes?
          fromUnit?.audioletOutputNodes?[outlet].disconnect toUnit.audioletInputNodes[inlet]
      # make new ones
      @makeConnections object

  makeConnections: (object) ->
    # FIXME: put method to get inlet funcs on model?
    connections = object.getConnections()
    fromUnit = object.get 'unit'
    return if not fromUnit # FIXME
    console.log 'redoing unit connections on', object.get 'text'
    unitConnections = {}
    for connection in connections
      [fromID, outlet, toID, inlet] = connection
      toUnit = @objects.get(toID)?.get('unit')
      toFunc = toUnit?.inlets[inlet]
      # connect audiolet groups
      if toUnit?.audioletInputNodes?
        # fromUnit? is this a bug? when would it not be there yet?
        fromUnit?.audioletOutputNodes?[outlet].connect toUnit.audioletInputNodes[inlet]
      # make make normal connections
      if toFunc
        unitConnections[outlet] or= []
        unitConnections[outlet].push toFunc
      else
        console.warn "no inlet func here, we must be loading a patch", object, @objects.get toID
    fromUnit.setConnections unitConnections
