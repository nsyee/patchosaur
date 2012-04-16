class Checkbox extends patchagogy.Unit
  # repeat initialization value whenever input received
  @names: ['checkbox']
  setup: (@objectModel, @args) ->
    arg = @args[0]
    @value = if arg == undefined then false else !!arg
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    @inlets = [@inlet]
    # set up custom GUI, managed by view
    el = $ document.createElement 'input'
    el.attr 'type', 'checkbox'
    el.css 'position', 'absolute'
    el.change (event) =>
      @value = event.target.checked
      @inlet 0, @value
    $('body').append el
    @objectModel.set customGui: el

  inlet: (arg) =>
    @out 0, @value

patchagogy.units.add Checkbox

