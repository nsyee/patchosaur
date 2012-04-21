class Trigger extends patchosaur.Unit
  @names: ['trigger', 't']
  # repeat input to many outputs, specified by arg
  # outlets called in right-to-left order
  setup: (@objectModel) ->
    @args = @objectModel.get 'unitArgs'
    @numOutlets = @args[0]
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: @numOutlets
    # make inlets from @call
    @inlets = [@inlet]

  inlet: (arg) =>
    for i in _.range(@numOutlets).reverse()
      @out i, arg

patchosaur.units.add Trigger
