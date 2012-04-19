class Coffee extends patchosaur.Unit
  @names: ['cs']
  setup: (@objectModel, @args) ->
    # take num inlets from num args
    @csFunc = CoffeeScript.eval @args[0]
    numInlets = @csFunc.length
    # bind this to instance, so you can do things like a counter:
    # (bang) -> @x = (@x or 0) + 1
    @csFunc = _.bind @csFunc, @
    # keep state, only call when left inlet fires
    @currArgs = []
    console.error @objectModel, numInlets
    @objectModel.set numInlets: numInlets
    @objectModel.set numOutlets: 1
    @inlets = @makeInlets numInlets, @call

  call: (i, arg) =>
    @currArgs[i] = arg
    if i == 0
      @out 0, @csFunc @currArgs...

patchosaur.units.add Coffee
