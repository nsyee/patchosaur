class Null extends patchosaur.Unit
  @names: ['null']
  setup: (@objectModel, @args) ->
    @objectModel.set numInlets: 0
    @objectModel.set numOutlets: 0

patchosaur.units.add Null
