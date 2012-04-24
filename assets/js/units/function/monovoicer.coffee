class MonoVoicer extends patchosaur.Unit
  # FIXME: test this
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
      # if it is playing, turn it off and play next
      curr = @ons[0]
      if curr and m.note == curr.note
        @ons.shift() # on for this note off
        @out 0, m
        if @ons[0]
          @out 0, @ons[0]
      else
        # filter it out of ons so it doesn't play later
        # FIXME: only filter one
        @ons = _.reject @ons, (onMessage) ->
          onMessage.note == m.note

patchosaur.units.add MonoVoicer
