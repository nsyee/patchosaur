
patchagogy = @patchagogy = @patchagogy or {}

ObjectView = Backbone.View.extend {
}

PatchView = Backbone.View.extend {
  el: $('#holder')

  addObject: (object) ->
    view = new ObjectView model: object
    # append it
}



$ ->
  patchagogy.patchView = new PatchView model: patchagogy.patch
