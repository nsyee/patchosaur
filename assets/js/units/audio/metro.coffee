class Metro extends patchosaur.Unit
  @names: ['metro']
  setup: (@objectModel) ->
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    @args = @objectModel.get 'unitArgs'
    [deltaT, rest...] = @args  # deltaT in ms
    a = patchosaur.audiolet
    @scheduler = a.scheduler
    bptPattern = new Pattern
    bptPattern.next = => @bpt
    @bpt = @beatsPerTick deltaT
    @event = @scheduler.play 1, bptPattern, (x) =>
      @out 0, true
    deltaTInlet = (x) => @setMsecs x
    @inlets = [deltaTInlet]

  stop: ->
    @scheduler.stop @event

  setMsecs: (ms) ->
    @bpt = @beatsPerTick ms
   
  beatsPerTick: (ms) =>
    @scheduler.bpm * ms / 60 / 1000

patchosaur.units.add Metro
