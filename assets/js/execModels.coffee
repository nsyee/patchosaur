patchagogy = @patchagogy = @patchagogy or {}

patchagogy.ExecClass = Backbone.Model.extend
  validate: ->
    # return error messages if any
    # assert id, which is object_class
  initialize: ->

patchagogy.ExecClasses = Backbone.Collection.extend
  model: patchagogy.ExecClass
  add: (ec) -> @add ec
