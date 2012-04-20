#= require patchosaur

$ ->
  # start the engines
  appController = new patchosaur.routes.App
  do Backbone.history.start
  console.log "Alright, we're rolling..."
