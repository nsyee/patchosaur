# FIXME: put this directly on models? that seems like a bad idea too
patchagogy = @patchagogy = @patchagogy or {}

  
    

patchagogy.UnitGraphView = Backbone.View.extend
  initialize: () ->
    # see uiviews for knowing when to redo connections
    @objects = @options.objects
    @objects.bind 'add', (object) =>

  # object model instantiates unit, available as object.unit

  # makeConnections: ->
  #   connections = @model.get 'connections'
  #   for outlet of connections
  #     for to in connections[outlet]
  #       toFunc = patchagogy.objects.get(toID).get('unitView').inlets[inlet]
