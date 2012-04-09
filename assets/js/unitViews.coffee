# FIXME: put this directly on models? that seems like a bad idea too
patchagogy = @patchagogy = @patchagogy or {}

patchagogy.UnitView = Backbone.View.extend
  initialize: ->
    # connections
    @model
    @toFuncs = {}
    # FIXME:
    # instantiate a unit from patchagogy.units
    # get it's fromFuncs
    # stop calling them things like that, call them
    # in and out, not to and from
  
  makeConnections: ->
    connections = @model.get 'connections'
    for outlet of connections
      for to in connections[outlet]
        toFunc = patchagogy.objects.get(toID).get('unitView').inlets[inlet]
    

patchagogy.UnitGraphView = Backbone.View.extend
  initialize: () ->
    # see uiviews for knowing when to redo connections
    @objects = @options.objects
    @objects.bind 'add', (object) =>
      unitView = new patchagogy.UnitView
        model: object
        patchView: @
      # set on model?
      object.set 'unit', @
