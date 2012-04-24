class MonoVoicer extends patchosaur.Unit
  # FIXME: test this
  # FIXME: document this
  @names: ['monovoicer']
  setup: (@objectModel) ->
    @objectModel.set numInlets: 2
    @objectModel.set numOutlets: 1
    @inlets = [@inlet1, @inlet2]
    @ons = []

  inlet1: (m) =>
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

  inlet2: =>
    # clear
    for noteOn in @ons
      noteOff = _.clone noteOn
      noteOff.velocity = 0
      @out 0, noteOff

    @ons = []

patchosaur.units.add MonoVoicer
