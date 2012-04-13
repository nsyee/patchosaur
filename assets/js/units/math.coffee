# take some for free from Math
mathFuncNames = Object.getOwnPropertyNames(Math).filter (prop) ->
  typeof Math[prop] == 'function'

funcs = _.map mathFuncNames, (name) ->
  func = Math[name]
  func.names = [name]
  func

funcs.push _.extend ((x, y) -> x + y),
  names: ['+']
funcs.push _.extend ((x, y) -> x - y),   names: ['-']
funcs.push _.extend ((x, y) -> x / y),   names: ['/']
funcs.push _.extend ((x, y) -> x * y),   names: ['*']
funcs.push _.extend ((x, y) -> x % y),
  names: ['&']
  tags: ['bitwise']
funcs.push _.extend ((x, y) -> x | y),   names: ['|'] # bitwise
funcs.push _.extend ((x, y) -> x ^ y),   names: ['^'] # bitwise
funcs.push _.extend ((x) -> ~ x),        names: ['~'] # bitwise
funcs.push _.extend ((x, y) -> x << y),  names: ['<<'] # left shift
funcs.push _.extend ((x, y) -> x >> y),  names: ['>>'] # sign-propagating right shift
funcs.push _.extend ((x, y) -> x >>> y), names: ['>>>'] # 0-fill right shift
funcs.push _.extend ((x, y) -> x == y),  names: ['==']
funcs.push _.extend ((x, y) -> x != y),  names: ['!=']
funcs.push _.extend ((x, y) -> x > y),   names: ['>']
funcs.push _.extend ((x, y) -> x < y),   names: ['<']
funcs.push _.extend ((x, y) -> x >= y),  names: ['>=']
funcs.push _.extend ((x, y) -> x <= y),  names: ['<=']
funcs.push _.extend ((x, y) -> x && y),  names: ['&&', 'and'] # logical
funcs.push _.extend ((x, y) -> x || y),  names: ['||', 'or'] # logical
funcs.push _.extend ((x) -> not x),      names: ['!', 'not'] # logical

for func in funcs
  do (func) ->
    class MathFunc extends patchagogy.Unit
      @names = func.names
      @tags  = (func.tags or []).concat ['math']
      setup: (@objectModel, @args) ->
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


