
patchagogy = @patchagogy = @patchagogy or {}

patchagogy.ObjectView = Backbone.View.extend {
  initialize: () -> do @render
  render: () ->
    console.log 'rendering object view', @
    @
}

patchagogy.PatchView = Backbone.View.extend {
  el: $('#holder')
  initialize: () ->
    @patch.bind 'add', (object) ->
      #new object view!!!
      #see todo list app:
      #http://documentcloud.github.com/backbone/docs/todos.html
}
