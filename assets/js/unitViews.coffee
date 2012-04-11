# FIXME: put this directly on models? that seems like a bad idea too
patchagogy = @patchagogy = @patchagogy or {}

patchagogy.UnitGraphView = Backbone.View.extend
  initialize: () ->
    # see uiviews for knowing when to redo connections
    @objects = @options.objects

    @objects.bind 'remove', (object) =>
      object.get('unit').stop()

    @objects.bind 'add change:text change:connections', (changedObject) =>
      affected = @objects.connectedFrom changedObject
      _.each affected, (object) =>
        @makeConnections object

  # object model instantiates unit, available as object.unit

  makeConnections: (object) ->
    # FIXME: put method to get inlet funcs on model?
    connections = object.get 'connections'
    unit = object.get 'unit'
    console.log 'redoing unit connections on', object.get 'text'
    unitConnections = {}
    for outlet of connections
      unitConnections[outlet] = []
      for [toObjID, toIndex] in connections[outlet]
        toFunc = @objects.get(toObjID)?.get('unit').inlets[toIndex]
        if toFunc
          unitConnections[outlet].push toFunc
        else
          console.warn "no inlet func here, we must be loading a patch"
    unit.setConnections unitConnections
