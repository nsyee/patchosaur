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

  index: () -> console.log 'index controller'
}


