
patchagogy = @patchagogy = @patchagogy or {}

patchagogy.ObjectView = Backbone.View.extend {
  initialize: () -> do @render
  render: () ->
    console.log 'rendering object view', @
    @
}

patchagogy.PatchView = Backbone.View.extend {
  el: $('#holder')
}

$ ->
  patchagogy.patchView = new patchagogy.PatchView model: patchagogy.patch
