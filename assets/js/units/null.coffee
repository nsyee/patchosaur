class Null extends patchagogy.Unit
  @names: ['null']
  setup: (@objectModel, @args) ->
    @objectModel.set numInlets: 0
    @objectModel.set numOutlets: 0

patchagogy.units.add Null
