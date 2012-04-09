patchagogy = @patchagogy = @patchagogy or {}

# FIXME: do you want each inlet to have a func, or one func for all? both?
# both.
# nah, maybe just inlet and outlet calls
#
# are these, models, views, what's what.

patchagogy.ExecClass = Backbone.Model.extend
  validate: ->
    # return error messages if any
    # assert id, which is object_class
  initialize: ->
    console.log 'calling inialiaze on exec class', @

patchagogy.ExecClasses = Backbone.Collection.extend
  model: patchagogy.ExecClass
  add: (ec) -> @add ec
