class Makenote extends patchosaur.Unit
  # FIXME: document this
  @names: ['makenote']
  setup: (@objectModel) ->
    @objectModel.set numInlets: 2
    @objectModel.set numOutlets: 1
    [note, velocity] = @objectModel.get 'unitArgs'
    velocity ?= 100
    @current = _.extend {note, velocity},
      type: 'noteOn'

    @inlets = [@inlet1, @inlet2]

  inlet1: (note) =>
    event = {note}
    event = _.defaults event, @current
    @out 0, event

  inlet2: (velocity) =>
    @current['velocity'] = velocity

patchosaur.units.add Makenote
