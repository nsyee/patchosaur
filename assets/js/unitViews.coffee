# FIXME: put this directly on models? that seems like a bad idea too
patchagogy = @patchagogy = @patchagogy or {}

  
    

patchagogy.UnitGraphView = Backbone.View.extend
  initialize: () ->
    # see uiviews for knowing when to redo connections
    @objects = @options.objects
    @objects.bind 'add', (object) =>
      console.log "unit views object add:", object
      @makeConnections object

  # object model instantiates unit, available as object.unit

  makeConnections: (object) ->
    # have this do a model get affected objects and operate on all
    # put method to get inlet funcs on model?
    connections = object.get 'connections'
    for outlet of connections
      for to in connections[outlet]
        toFunc = @objects.get(toID).get('unitView').inlets[inlet]
