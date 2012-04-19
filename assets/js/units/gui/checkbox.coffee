class Checkbox extends patchosaur.Unit
  # repeat initialization value whenever input received
  @names: ['checkbox', 'cb']
  @tags: ['gui']
  setup: (@objectModel, @args) ->
    arg = @args[0]
    @value = if arg == undefined then false else !!arg
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    @inlets = [@inlet]
    # set up custom GUI, managed by view
    el = $ document.createElement 'input'
    el.attr 'type', 'checkbox'
    el.change (event) =>
      @value = event.target.checked
      @inlet 0, @value
    $('body').append el
    @el = el
    @objectModel.set customGui: el

  inlet: (arg) =>
    # set on box
    @value = !!arg
    @el.prop 'checked', @value
    # output
    @out 0, @value

patchosaur.units.add Checkbox

