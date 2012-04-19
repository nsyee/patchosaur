class Dump extends patchosaur.Unit
  # repeat initialization value whenever input received
  @names: ['dump']
  setup: (@objectModel, @args) ->
    @value = @args[0] or true
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    @inlets = [@inlet]

  inlet: (arg) =>
    @out 0, @value

patchosaur.units.add Dump

