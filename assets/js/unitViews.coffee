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
      prevConns = changedObject.previous 'connections'
      # make connections on affected objects
      affected = @objects.connectedFrom changedObject
      _.each affected, (object) =>
        # remove all previous audiolet connections
        # FIXME: rethink this
        for outlet of prevConns
          for [toObjID, toIndex] in prevConns[outlet]
            fromUnit = object.get 'unit'
            toUnit = @objects.get(toObjID)?.get('unit')
            if toUnit?.audioletGroup?
              fromUnit.audioletGroup?.disconnect toUnit.audioletGroup
        # make func and audiolet connections
        @makeConnections object

  makeConnections: (object) ->
    # FIXME: put method to get inlet funcs on model?
    connections = object.get 'connections'
    fromUnit = object.get 'unit'
    console.log 'redoing unit connections on', object.get 'text'
    unitConnections = {}
    for outlet of connections
      unitConnections[outlet] = []
      for [toObjID, toIndex] in connections[outlet]
        toUnit = @objects.get(toObjID)?.get('unit')
        toFunc = toUnit?.inlets[toIndex]
        # connect audiolet groups
        if toUnit?.audioletGroup?
          fromUnit.audioletGroup?.connect toUnit.audioletGroup
        # make make normal connections
        if toFunc
          unitConnections[outlet].push toFunc
        else
          console.warn "no inlet func here, we must be loading a patch", object, @objects.get toObjID
    fromUnit.setConnections unitConnections
