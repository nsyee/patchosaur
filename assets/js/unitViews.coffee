# FIXME: put this directly on models? that seems like a bad idea too
patchagogy = @patchagogy = @patchagogy or {}

patchagogy.UnitGraphView = Backbone.View.extend
  initialize: () ->
    # see uiviews for knowing when to redo connections
    @objects = @options.objects
    @objects.bind 'add', (object) =>
      console.log "unit views object add:", object
      @makeConnections object
    @objects.bind 'change:connections', (object) =>
      # FIXME: this works too hard?
      affecteds = @objects.connectedFrom object
      _.each affecteds, (affected) => @makeConnections affected

  # object model instantiates unit, available as object.unit

  makeConnections: (object) ->
    # have this do a model get affected objects and operate on all
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
