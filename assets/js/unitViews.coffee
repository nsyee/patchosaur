# FIXME: put this directly on models? that seems like a bad idea too
patchagogy = @patchagogy = @patchagogy or {}

patchagogy.UnitGraphView = Backbone.View.extend
  initialize: () ->
    # see uiviews for knowing when to redo connections
    @objects = @options.objects
    @objects.bind 'add', (object) =>
      console.log "unit views object add:", object
      @makeConnections object

    @objects.bind 'remove', (object) =>
      object.get('unit').stop()

    @objects.bind 'change:text change:connections', (object) =>
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
        toFunc = @objects.get(toObjID).get('unit').inlets[toIndex]
        unitConnections[outlet].push toFunc
    unit.setConnections unitConnections
