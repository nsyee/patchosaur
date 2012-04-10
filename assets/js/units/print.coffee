class Print extends patchagogy.Unit
  setup: (@objectModel, @args) ->
    @label = @args[0] or "print"
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 0
    # make inlets from @call
    @inlets = [@inlet]

  inlet: (arg) =>
    console.log "#{@label}:", arg

patchagogy.units['print'] = Print

