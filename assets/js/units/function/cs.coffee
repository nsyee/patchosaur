class Coffee extends patchosaur.Unit
  @names: ['cs']
  setup: (@objectModel) ->
    # take num inlets from num args
    @csFunc = CoffeeScript.eval objectModel.get('unitArgs')[0]
    numInlets = @csFunc.length
    # bind this to new obj, so you can do things like a counter:
    # (bang) -> @x = (@x or 0) + 1
    @csFunc = _.bind @csFunc, {}
    # keep state, only call when left inlet fires
    @currArgs = []
    @objectModel.set numInlets: numInlets
    @objectModel.set numOutlets: 1
    @inlets = @makeInlets numInlets, @call

  call: (i, arg) =>
    @currArgs[i] = arg
    if i == 0
      @out 0, @csFunc @currArgs...

patchosaur.units.add Coffee
