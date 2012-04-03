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
    patchagogy.patch = new patchagogy.Patch
    patchagogy.patchView = new patchagogy.PatchView patch: patchagogy.patch
    console.log 'created patch:', patchagogy.patch
    # keep these test cases around
    x = patchagogy.patch.newObject {text: 'hey'}
    x = patchagogy.patch.newObject {text: "hey2 1.0 987 'hey there'"}
    x = patchagogy.patch.newObject {text: "hey3 3 '[1, 23, 8]' '{\"2\": 3}'"}
    @createObject {
      text: 'hey there whoa'
      position: [200, 220]
    }
}
