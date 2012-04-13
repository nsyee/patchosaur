# take some for free from Math
mathFuncNames = Object.getOwnPropertyNames(Math).filter (prop) ->
  typeof Math[prop] == 'function'

funcs = _.map mathFuncNames, (name) ->
  func = Math[name]
  func.names = [name]
  func

funcs.push _.extend ((x, y) -> x + y),   names: ['+']
funcs.push _.extend ((x, y) -> x - y),   names: ['-']
funcs.push _.extend ((x, y) -> x / y),   names: ['/']
funcs.push _.extend ((x, y) -> x * y),   names: ['*']
funcs.push _.extend ((x, y) -> x % y),   names: ['&'] # bitwise
funcs.push _.extend ((x, y) -> x | y),   names: ['|'] # bitwise
funcs.push _.extend ((x, y) -> x ^ y),   names: ['^'] # bitwise
funcs.push _.extend ((x) -> ~ x),        names: ['~'] # bitwise
funcs.push _.extend ((x, y) -> x << y),  names: ['<<'] # left shift
funcs.push _.extend ((x, y) -> x >> y),  names: ['>>'] # sign-propagating right shift
funcs.push _.extend ((x, y) -> x >>> y), names: ['>>>'] # 0-fill right shift

for func in funcs
  console.log func, 'hawefawefa'
  do (func) ->
    class MathFunc extends patchagogy.Unit
      @names = func.names
      setup: (@objectModel, @args) ->
        # FIXME: let args set defaults
        @func = func
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


