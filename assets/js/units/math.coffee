# take some for free from Math
mathFuncNames = Object.getOwnPropertyNames(Math).filter (prop) ->
  typeof Math[prop] == 'function'

for funcName in mathFuncNames
  do (funcName) ->
    class MathFunc extends patchagogy.Unit
      @names = [funcName]
      setup: (@objectModel, @args) ->
        # FIXME: let args set defaults
        @func = Math[funcName]
        numInlets = @func.length
        @currArgs = [0, @args...]
        @objectModel.set numInlets: numInlets
        @objectModel.set numOutlets: 1
        @inlets = @makeInlets numInlets, @call

      call: (i, arg) =>
        @currArgs[i] = arg
        if i == 0
          @out 0, @func @currArgs...

    patchagogy.units.add MathFunc


