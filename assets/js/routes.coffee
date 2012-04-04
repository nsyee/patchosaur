# FIXME: require views and models

patchagogy = @patchagogy = @patchagogy or {}

patchagogy.controllers = {}

patchagogy.controllers.App = Backbone.Router.extend {
  routes:
    "index":       'index'
    "help":        'help'
    "help/:unit":  'help'
    "patch/:file": 'patch'
    # default
    "*path":       'index'

  index: () ->
    patchagogy.paper = Raphael("holder", "100%", "100%")
    patchagogy.patch = new patchagogy.Patch
    patchagogy.patchView = new patchagogy.PatchView
      patch: patchagogy.patch
    console.log 'created patch:', patchagogy.patch
    # # keep these test cases around
    one = patchagogy.patch.newObject {x: 100, y: 100, text: 'hey ZOMG 1'}
    two = patchagogy.patch.newObject {x: 250, y: 250, text: 'hey ZOMG 2'}
    window.one = one
    window.two = two
    one.connect(0, two.id, 0)
    console.log 'object one', one, 'connected to two', two
    # patchagogy.patch.newObject {text: "hey2 1.0 987 'hey there'"}
    # patchagogy.patch.newObject {text: "hey3 3 '[1, 23, 8]' '{\"2\": 3}'"}
}
