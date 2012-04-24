class Metro extends patchosaur.Unit
  # outputs scheduler time, left inlet is state
  # right inlet is tempo (delta ms)
  @names: ['metro']
  setup: (@objectModel) ->
    @objectModel.set numInlets: 2
    @objectModel.set numOutlets: 1
    @args = @objectModel.get 'unitArgs'
    # read args
    ms = @args[0] # delta in ms
    ms ?= 1000
    if not _.isNumber ms
      error = new Error "metro got invalid ms argument: must be number, was #{ms}"
      console.error e, ms
      @objectModel.set {error}
    state  = @args[1]
    state  ?= true
    state = !! state
    # set up
    a = patchosaur.audiolet
    @scheduler = a.scheduler
    @bpt = @beatsPerTick ms
    @inlets = [@toggleInlet, @setDeltaMSInlet]
    do @start if state

  toggleInlet: (state) =>
    if state
      do @start
    else
      do @stop

  setDeltaMSInlet: (ms) =>
    @bpt = @beatsPerTick ms
   
  beatsPerTick: (ms) =>
    @scheduler.bpm * ms / 60 / 1000

  start: ->
    do @stop
    bptPattern = new Pattern
    bptPattern.next = => @bpt
    @event = @scheduler.play 1, bptPattern, =>
      @out 0, @scheduler.seconds

  stop: -> @scheduler?.stop @event

patchosaur.units.add Metro
