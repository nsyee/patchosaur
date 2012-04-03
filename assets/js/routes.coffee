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

  createObject: (attrs) ->
    model = patchagogy.patch.newObject attrs
    view = new patchagogy.ObjectView _.extend attrs, \
      {model: model}


  index: () ->
    patchagogy.patch = new patchagogy.Patch
    console.log 'creating patch:', patchagogy.patch
    # keep these test cases around
    x = patchagogy.patch.newObject {text: 'hey'}
    x = patchagogy.patch.newObject {text: "hey2 1.0 987 'hey there'"}
    x = patchagogy.patch.newObject {text: "hey3 3 '[1, 23, 8]' '{\"2\": 3}'"}
    @createObject {
      text: 'hey there whoa'
      position: [200, 220]
    }
}


