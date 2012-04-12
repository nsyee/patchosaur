#= require patchagogy

$ ->
  # start the engines
  appController = new patchagogy.routes.App
  do Backbone.history.start
  console.log 'aww... shit.'
