patchagogy = patchagogy or {}

patchagogy.Object = Backbone.Model.extend {
  defaults:
    text: ''
    connections: []
    raphaelBox: null
  initialize: ->
    console.log "initializing object #{@}"
    @bind 'change:text', ->
      # do some audio stuff
}

patchagogy.Patch = Backbone.Collection.extend {
  model: patchagogy.Object
}
