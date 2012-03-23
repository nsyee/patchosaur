
patchagogy = @patchagogy = @patchagogy or {}

PatchView = Backbone.View.extend {
  el: $('#holder')
}


$ ->
  patchagogy.patchView = new PatchView model: patchagogy.patch
  console.log patchagogy
