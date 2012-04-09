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
      @makeConnections object
      # FIXME: also make for upstream or downstream?!
      # these are only changes to outlets, so maybe you
      # don't care

  # object model instantiates unit, available as object.unit

  makeConnections: (object) ->
    # have this do a model get affected objects and operate on all
    # FIXME: put method to get inlet funcs on model?
    console.log object
    connections = object.get 'connections'
    unitConnections = {}
    for outlet of connections
      unitConnections[outlet] = []
      for to in connections[outlet]
        console.log to
        #toFunc = @objects.get(toID).get('unit').inlets[inlet]
    #unit.setConnections 
