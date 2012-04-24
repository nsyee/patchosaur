class Trigger extends patchosaur.Unit
  @names: ['route']
  # FIXME: document this
  setup: (@objectModel) ->
    @args = @objectModel.get 'unitArgs'
    @numOutlets = @args.length + 1
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
    else
      # no match
      # pass whole message out right outlet
      # FIXME: test
      @out (@numOutlets - 1), arg

patchosaur.units.add Trigger
