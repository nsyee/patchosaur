class Coffee extends patchagogy.Unit
  setup: (@objectModel, @args) ->
    # take num inlets from num args
    @csFunc = CoffeeScript.eval @args[0]
    numInlets = @csFunc.length
    # bind this to instance... useful?
    # could prevent pollution.
    @csFunc = _.bind @csFunc, @
    # keep state, only call when left inlet fires
    @currArgs = []
    @objectModel.set numInlets: numInlets
    @objectModel.set numOutlets: 1
    @inlets = @makeInlets numInlets, @call

  call: (i, arg) =>
    @currArgs[i] = arg
    if i == 0
      @out 0, @csFunc @currArgs...

patchagogy.units['cs'] = Coffee

