class Gate extends patchosaur.Unit
  @names: ['gate', 'spigot']
  # FIXME: document this
  setup: (@objectModel) ->
    @state = @objectModel.get('unitArgs')[0]
    @state ?= false
    @state = !! @state
    @objectModel.set numInlets: 2
    @objectModel.set numOutlets: 1
    @inlets = [@inlet1, @inlet2]

  inlet1: (arg) =>
    if @state
      @out 0, arg

  inlet2: (arg) =>
    @state = !! arg

patchosaur.units.add Gate
