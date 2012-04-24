class Switch extends patchosaur.Unit
  # http://cycling74.com/docs/max5/refpages/max-ref/switch.html
  @names: ['switch']
  setup: (@objectModel) ->
    [numInlets, @state] = @objectModel.get('unitArgs')
    numInlets ?= 2
    @state ?= 1
    @objectModel.set numInlets: numInlets + 1
    @objectModel.set numOutlets: 1
    @inlets = @makeInlets (numInlets + 1), @call

  call: (i, args...) =>
    if i == 0
      @state = args[0]
    else
      if i == @state
        @out 0, args...

patchosaur.units.add Switch
