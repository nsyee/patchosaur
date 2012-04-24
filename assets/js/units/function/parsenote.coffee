class Parsenote extends patchosaur.Unit
  # FIXME: document this
  @names: ['parsenote']
  setup: (@objectModel) ->
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 2
    @inlets = [@inlet]

  inlet: (note) =>
    return if not note.type == 'noteOn'
    {velocity, note} = note
    @out 1, velocity
    @out 0, note

patchosaur.units.add Parsenote
