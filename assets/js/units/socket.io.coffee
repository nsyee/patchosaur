class Socket extends patchagogy.Unit
  # repeat initialization value whenever input received
  @names: ['socket.io']
  setup: (@objectModel, @args) ->
    @event = @args[0] or 'midi'
    @socket = do io.connect
    @socket.on @event, (args...) =>
      @out 0, args
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    @inlets = [@inlet]

  inlet: (args...) =>
    @socket.emit @event, args...

patchagogy.units.add Socket

