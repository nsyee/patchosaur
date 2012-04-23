class MonoVoicer extends patchosaur.Unit
  @names: ['monovoicer']
  # FIXME: document this
  setup: (@objectModel) ->
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    @inlets = [@inlet]
    @ons = []

  inlet: (m) =>
    # note on
    if m.type == 'noteOn' and m.velocity > 0
      # turn off playing note
      curr = @ons[0]
      if curr
        noteOff = _.clone curr
        noteOff.velocity = 0
        @out 0, noteOff
      # pass input
      @out 0, m
      # remember it
      @ons.unshift m
    # note off
    else if m.type == 'noteOn' and m.velocity == 0
      # if it is playing, turn it off
      curr = @ons[0]
      if m.note == curr.note
        noteOff = _.clone @ons.shift()
        noteOff.velocity = 0
        @out 0, noteOff
      else
        # filter it out of ons so it doesn't play later
        # FIXME
        # only filter one out?
        @ons = _.filter @ons, (onMessage) ->
          onMessage.note == m.note
      # play next
      curr = @ons.shift()
      if curr
        @out 0, curr

patchosaur.units.add MonoVoicer
