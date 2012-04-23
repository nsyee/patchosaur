class Slider extends patchosaur.Unit
  # repeat initialization value whenever input received
  @names: ['range']
  @tags: ['gui']
  setup: (@objectModel) ->
    # FIXME: document
    @args = @objectModel.get 'unitArgs'
    [min, max, step, value] = @args
    # set defaults
    min ?= 0
    max ?= 1
    step ?= 0.01
    value ?= 0.5
    id = _.uniqueId 'rangegui_'
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    @inlets = [@inlet]
    # set up custom GUI, managed by view
    el = $ document.createElement 'input'
    attrs = _.extend {
      type: 'range'
    }, {min, max, step, value, id}
    el.attr attrs
    el.css
      width: '100px'
    el.change (event) =>
      @value = $(event.target).prop 'value'
      @inlet @value
    $('body').append el
    @el = el
    @objectModel.set customGuiId: id

  inlet: (arg) =>
    @value = arg
    # set on element
    @el.prop value: @value
    # output
    @out 0, @value

patchosaur.units.add Slider

