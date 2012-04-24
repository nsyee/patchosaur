class Dump extends patchosaur.Unit
  # repeat initialization value whenever input received
  @names: ['dump', 'd']
  setup: (@objectModel) ->
    @args = @objectModel.get('unitArgs')
    if _.isEmpty @args
      @args = [true]
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: @args.length
    @inlets = [@inlet]

  inlet: (b) =>
    for value, i in @args
      @out i, value

patchosaur.units.add Dump

