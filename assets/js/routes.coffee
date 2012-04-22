patchosaur = @patchosaur ?= {}

patchosaur.routes = {}

patchosaur.routes.App = Backbone.Router.extend {
  routes:
    "index":       'index'
    "help":        'help'
    "help/:unit":  'help'
    "patch/:file": 'patch'
    # default
    "*path":       'index'

  index: () ->
    patchosaur.paper = Raphael("holder", "100%", "100%")
    patchosaur.objects = new patchosaur.Objects
    patchosaur.patchView = new patchosaur.PatchView
      objects: patchosaur.objects
      paper:   patchosaur.paper
    patchosaur.unitGraphView = new patchosaur.UnitGraphView
      objects: patchosaur.objects
    console.log 'created patch:', patchosaur.objects
    patchosaur.objects.load()
}
