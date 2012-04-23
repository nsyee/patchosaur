class Trigger extends patchosaur.Unit
  @names: ['route']
  # FIXME: document this
  setup: (@objectModel) ->
    @args = @objectModel.get 'unitArgs'
    @numOutlets = @args.length
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: @numOutlets
    @routeHash = {}
    for match, i in @args
      @routeHash[match] = i
    @inlets = [@inlet]

  inlet: (arg) =>
    if _.isArray arg
      [match, toPass...] = arg
    else
      match = arg
      toPass = arg

    if match of @routeHash
      outlet = @routeHash[match]
      @out outlet, toPass

patchosaur.units.add Trigger
