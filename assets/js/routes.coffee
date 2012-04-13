# FIXME: require views and models

patchagogy = @patchagogy = @patchagogy or {}

patchagogy.routes = {}

patchagogy.routes.App = Backbone.Router.extend {
  routes:
    "index":       'index'
    "help":        'help'
    "help/:unit":  'help'
    "patch/:file": 'patch'
    # default
    "*path":       'index'

  index: () ->
    patchagogy.paper = Raphael("holder", "100%", "100%")
    patchagogy.objects = new patchagogy.Objects
    patchagogy.patchView = new patchagogy.PatchView
      objects: patchagogy.objects
      paper:   patchagogy.paper
    patchagogy.unitGraphView = new patchagogy.UnitGraphView
      objects: patchagogy.objects
    console.log 'created patch:', patchagogy.objects
    patchagogy.objects.load()
}
