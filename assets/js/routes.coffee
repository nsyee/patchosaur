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
    patchagogy.patch = new patchagogy.Patch objects: patchagogy.objects
    patchagogy.patchView = new patchagogy.PatchView
      objects: patchagogy.objects
    patchagogy.unitGraphView = new patchagogy.UnitGraphView
      objects: patchagogy.objects
    console.log 'created patch:', patchagogy.objects
    # # keep these test cases around
    one   = patchagogy.objects.newObject {x: 100, y: 100, text: 'hey "ZOMG", 1'}
    two   = patchagogy.objects.newObject {x: 100, y: 250, text: 'hey {"ZOMG": 2, "heythere": true}'}
    three = patchagogy.objects.newObject {x: 100, y: 350, text: 'cs "(x) -> x*x"'}
    three = patchagogy.objects.newObject {x: 100, y: 450, text: 'identity 1'}
    one.connect(0, two.id, 0)
    two.connect(0, three.id, 0) #FIXME: not connecting? js error...
    console.log 'object one', one, 'connected to two', two
    # patchagogy.patch.newObject {text: "hey2 1.0 987 'hey there'"}
    # patchagogy.patch.newObject {text: "hey3 3 '[1, 23, 8]' '{\"2\": 3}'"}
    # #FIXME: this will fail for now
    patchagogy.patch.save()
}
