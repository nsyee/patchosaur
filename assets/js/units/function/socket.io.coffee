class Socket extends patchosaur.Unit
  # repeat initialization value whenever input received
  @names: ['socket.io']
  setup: (@objectModel) ->
    @args = @objectModel.get 'unitArgs'
    @event = @args[0] or 'midi'
    @socket = do io.connect
    @socket.on @event, (args...) =>
      @out 0, args...
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    @inlets = [@inlet]

  inlet: (args...) =>
    @socket.emit @event, args...

patchosaur.units.add Socket

