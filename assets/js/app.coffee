#= require patchagogy

$ ->
  # start the engines
  appController = new patchagogy.routes.App
  do Backbone.history.start
  console.log 'aww... shit.'

  # FIXME: put this in a unit
  socket = do io.connect
  socket.on 'status', (status) -> console.log 'socket.io status:', status

