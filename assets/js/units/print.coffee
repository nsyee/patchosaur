class Print extends patchosaur.Unit
  @names: ['print']
  setup: (@objectModel, @args) ->
    @label = @args[0] or "print"
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 0
    # make inlets from @call
    @inlets = [@inlet]

  inlet: (arg) =>
    console.log "#{@label}:", arg

patchosaur.units.add Print

