#= require unitBase

# FIXME: put this directly on models? that seems like a bad idea too
patchagogy = @patchagogy = @patchagogy or {}

DEFAULT_UNIT = 'identity'

patchagogy.UnitGraphView = Backbone.View.extend
  initialize: () ->
    # see uiviews for knowing when to redo connections
    @objects = @options.objects

    @objects.bind 'remove', (object) =>
      object.get('unit').stop()

    @objects.bind 'add change:text', (o) =>
      o.get('unit')?.stop()
      UnitClass = patchagogy.units.get o.get 'unitClassName'
      if not UnitClass
        # FIXME: just don't make it?
        console.warn "no unit class found for #{o.get 'unitClassName'}, using #{DEFAULT_UNIT}"
        UnitClass = patchagogy.units.get DEFAULT_UNIT
      o.set unit: new UnitClass o, o.get 'unitArgs'

    # redo connections
    @objects.bind 'add change:text change:connections', (changedObject) =>
      prevConns = changedObject.getPreviousConnections()
      # make connections on affected objects
      affected = @objects.connectedFrom changedObject
      _.each affected, (object) =>
        # remove all previous audiolet connections
        # FIXME: rethink this
        for connection in prevConns
          [fromID, outlet, toID, inlet] = connection
          fromUnit = object.get 'unit'
          toUnit = @objects.get(toID)?.get('unit')
          if toUnit?.audioletNodes?
            fromUnit.audioletNodes?[outlet].disconnect toUnit.audioletNodes[inlet]
        # make func and audiolet connections
        @makeConnections object

  makeConnections: (object) ->
    # FIXME: put method to get inlet funcs on model?
    connections = object.getConnections()
    fromUnit = object.get 'unit'
    console.log 'redoing unit connections on', object.get 'text'
    unitConnections = {}
    for connection in connections
      [fromID, outlet, toID, inlet] = connection
      toUnit = @objects.get(toID)?.get('unit')
      toFunc = toUnit?.inlets[inlet]
      # connect audiolet groups
      if toUnit?.audioletNodes?
        fromUnit.audioletNodes?[outlet].connect toUnit.audioletNodes[inlet]
      # make make normal connections
      if toFunc
        unitConnections[outlet] or= []
        unitConnections[outlet].push toFunc
      else
        console.warn "no inlet func here, we must be loading a patch", object, @objects.get toID
    fromUnit.setConnections unitConnections
