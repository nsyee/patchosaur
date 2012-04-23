#= require templates/help

patchosaur = @patchosaur ?= {}

# 30 times a second
REFRESH_RATE = 1000 / 30

throttle = (f) => _.throttle f, REFRESH_RATE

patchosaur.ObjectView = Backbone.View.extend {
  initialize: () ->
    @patchView = @options.patchView
    @p = @patchView.paper
    @id = @cid
    @model.set 'view', @
    # dom elements
    @connectionEls = []
    @inlets  = []
    @outlets = []
    @raphaelBox = undefined
    @raphaelText = undefined
    @customGui = @getCustomGui()
    # make it
    do @render
    # bind events
    @model.bind 'change:customGuiId', =>
      @customGui?.remove()
      @customGui = @getCustomGui()
      @place()
    @model.bind 'remove', => do @clearElems
    @model.bind 'change:x change:y', => do @place
    @bind 'redrawConnections', => do @drawConnections
    @model.bind 'change:numInlets change:numOutlets change:text change:error', =>
      do @clearElems
      do @render

  getCustomGui: ->
    $ document.getElementById @model.get 'customGuiId'

  clearElems: ->
    elemsToRemove = _.flatten [
      @raphaelSet,
      @raphaelBox,
      @raphaelText,
      @inlets,
      @outlets,
      @customGui
      @connectionEls
    ]
    el?.remove() for el in elemsToRemove

  clear: () ->
    @model.collection.remove(@model)

  edit: () ->
    @raphaelSet.hide()
    editEl = $ document.createElement 'input'
    bbox = @raphaelBox.getBBox()
    $('body').append editEl
    editEl.focus().select().val @model.get 'text'
    editEl.css
      position: 'absolute'
      left: bbox.x - 1
      top: bbox.y - 1
    editEl.on 'focusout', (event) =>
      @model.set 'text', editEl.val() or 'null'
      @model.set new: false
      @raphaelSet.show()
      editEl.remove()
      @patchView.fsm.saveObjectEdit()
    editEl.on 'keydown', ->
      do editEl.blur if event.which == 13 # enter
    editEl.on 'keydown', =>
      if event.which == 27 # esc
        editEl.val @model.get 'text' # restore
        do editEl.blur

  place: () ->
    x = @model.get 'x'
    y = @model.get 'y'
    elems = _.flatten [
      @raphaelBox
      @raphaelText
      @inlets
      @outlets
      # @glowee #FIXME uncomment, set offset
    ]
    for elem in elems
      elem.attr
        x: x + (elem.offsetX or 0)
        y: y + (elem.offsetY or 0)
    @p.safari()
    # move custom GUI
    if @customGui
      box = @raphaelBox.getBBox()
      @customGui.css
        left: box.x + box.width + 3
        top: box.y
        position: 'absolute'

  drawConnections: () ->
    # FIXME: update line instead of making new one?
    for line in @connectionEls
      line.remove()
    @connectionEls = []
    connections = @model.getConnections()
    for connection in connections
      [fromID, outlet, toID, inlet] = connection
      toModel = @model.collection.get(toID)
      toElem = toModel?.get('view')?.inlets[inlet]
      continue if not toElem # it isn't there yet
      fromElem = @outlets[outlet]
      continue if not fromElem # FIXME: huh?
      bbox1 = fromElem.getBBox()
      x1 = bbox1.x + bbox1.width / 2
      y1 = bbox1.y + bbox1.height
      bbox2 = toElem.getBBox()
      x2 = bbox2.x + bbox2.width / 2
      y2 = bbox2.y
      conn = @p.path "#M#{x1},#{y1}L#{x2},#{y2}"
      @connectionEls.push conn
      # disconnect with alt-click or ctrl-click
      conn.click (event) =>
        if event.altKey or event.ctrlKey
          @model.disconnect outlet, toID, inlet

  setOffset: (onEl, fromEl) ->
    # set offset on an element for placement
    onEl.offsetX = onEl.attrs.x - fromEl.attrs.x
    onEl.offsetY = onEl.attrs.y - fromEl.attrs.y

  drawTextElem: (text, x, y) ->
    textElem = @p.text x, y, text
    textElem.attr
      "font-size": 11
      "font-family": "monospace"
    box = textElem.getBBox()
    # reposition so saves/restores work
    textElem.attr
      x: x + box.width / 2
      y: y + box.height / 2
    textElem

  drawRectElem: (textElem) ->
    box = textElem.getBBox()
    # set min width based on number of inlets/outlets
    numLets = Math.max @model.get('numInlets'),
                       @model.get('numOutlets')
    minWidth = numLets * 12
    box.width = minWidth if box.width < minWidth
    pad = 2
    # set up colors for errors and comments
    if @model.get 'error'
      color = '#d03'
    else
      color = '#30a'

    if @model.isComment()
      strokeOpacity = 0
    else
      strokeOpacity = 1

    # make it
    rect = @p.rect(
      box.x - pad,              # x
      box.y - pad + 1,          # y
      box.width + (pad*2),      # width
      box.height + (pad*2) - 1, # height
      2                         # corner radius
    ).attr
      fill: color
      stroke: color
      "fill-opacity": 0
      "stroke-opacity": strokeOpacity
      "stroke-width": 2
      cursor: "move"
    @setOffset textElem, rect
    rect

  drawInletOutletElems: (rectElem) ->
    # FIXME: clean this up 
    # make inlets and outlets
    inlet.remove() for inlet in @inlets
    outlet.remove() for outlet in @outlets
    @inlets = []
    @outlets = []
    numInlets = @model.get 'numInlets'
    numOutlets = @model.get 'numOutlets'
    box = rectElem.getBBox()
    padding = 5
    width = box.width - (padding * 2)
    # FIXME duplicate code
    spacing = width / ((numInlets - 1) or 2)
    for inlet in _.range numInlets
      inletElem = @p.rect(
        box.x + padding - 3 + (inlet * spacing),
        box.y - 4,
        6, 4, 1)
      inletElem.attr fill: '#9b9'
      @inlets.push inletElem
    spacing = width / ((numOutlets - 1) or 2)
    for outlet in _.range numOutlets
      outletElem = @p.rect(
        box.x + padding - 3 + (outlet * spacing),
        box.height + box.y + 0,
        6, 4, 1)
      outletElem.attr fill: '#99f'
      @outlets.push outletElem

    _.each _.flatten([@outlets, @inlets]), (xlet) =>
      # offset for place()
      @setOffset xlet, rectElem
      # glow on hover
      xlet.hover (event) ->
        xlet.glowEl = xlet.glow()
      , (event) ->
        xlet.glowEl.remove()

    # bind outlet events
    _.each @outlets, (outlet, i) =>
      outlet.click (event) =>
        @glowee = outlet.glow()
        # @setOffset @glowee, rectElem
        anim = Raphael.animation {"stroke-width": 12}, 400
        anim = anim.repeat Infinity
        @glowee.animate anim
        @patchView.selectOutlet
          modelID: @model.id
          index: i
          el: @glowee

    # bind inlet events
    _.each @inlets, (inlet, i) =>
      inlet.click (event) =>
        @patchView.selectInlet
          modelID: @model.id
          index: i

  render: () ->
    # FIXME: break this up
    @raphaelSet?.remove()
    do @p.setStart
    x = @model.get 'x'
    y = @model.get 'y'
    text = @model.get 'text'
    if @model.isComment()
      text = @model.get 'unitArgs'
    @raphaelText = @drawTextElem text, x, y
    @raphaelBox = @drawRectElem(@raphaelText)
    @drawInletOutletElems @raphaelBox
    # set up dragging behavior and events
    startDrag = ->
      @ox = @attr 'x'
      @oy = @attr 'y'
      @animate({"fill-opacity": .3}, 200)
    endDrag = (event) ->
      @animate({"fill-opacity": 0}, 700)
    model = @model
    move = throttle (dx, dy) ->
      att = {x: @ox + dx, y: @oy + dy}
      # set on model, triggers events to redraw
      model.set att
    @raphaelBox.drag move, startDrag, endDrag
    @raphaelBox.dblclick => @patchView.fsm.editObject @
    @raphaelBox.click (event) =>
      if event.altKey or event.ctrlKey
        do @clear
    @raphaelSet = do @p.setFinish
}

patchosaur.PatchView = Backbone.View.extend {
  # FIXME: let the view make the #holder div?
  el: $('#holder')
  initialize: () ->
    @objects = @options.objects
    @paper = @options.paper # raphael paper
    @svgEl = @$el.children('svg').get 0
    @currentObjectView
    @fsm = do @makeFSM
    # bind model change events
    @objects.bind 'add', (object) =>
      objectView = new patchosaur.ObjectView
        model: object
        patchView: @
      do objectView.edit if do object.isNew

    @objects.bind 'add change:x change:y change:text change:connections change:numInlets change:numOutlets', (changedObject) =>
      affected = @objects.connectedFrom changedObject
      _.each affected, (object) ->
        view = object.get 'view'
        if view # could be going backwards
          view.trigger 'redrawConnections'

    # bind view event handlers
    @$el.on 'dblclick', (event) =>
      if not (event.target == @svgEl)
        return
      @fsm.createObject
        x: event.pageX
        y: event.pageY
        new: true

    # help
    do @generateHelp
    $(document).on 'keydown', (event) =>
      do @fsm.toggleHelp if event.which == 72 # "h"
    $('#help-link').on 'click', =>
      do @fsm.toggleHelp

  generateHelp: ->
    template = patchosaur.templates.help
    data = {}
    div = $ template data
    $('body').append div
    div.modal().modal('hide')
    @helpEl = div

  makeFSM: ->
    # https://github.com/jakesgordon/javascript-state-machine
    @fsm = StateMachine.create
      initial: 'ready'
      events: [
        {name: 'selectOutlet', from: '*', to: 'outletSelected'}
        {name: 'selectInlet', from: 'outletSelected', to: 'ready'}
        {name: 'editObject', from: 'ready', to: 'editingObject'}
        {name: 'createObject', from: 'ready', to: 'editingObject'}
        {name: 'saveObjectEdit', from: 'editingObject', to: 'ready'}
        # can only toggle help from ready
        {name: 'toggleHelp', from: 'ready', to: 'ready'}
        {
          name: 'escape'
          from: ['outletSelected', 'inletSelected']
          to: 'ready'
        }
      ]
      callbacks:
        onselectOutlet: (event, from, to, data) =>
          @_setActiveOutlet data
        onselectInlet: (event, from, to, data) =>
          @_setInlet data
        oncreateObject: (event, from, to, object) =>
          @objects.newObject object
        oneditObject: (event, from, to, object) =>
          object.edit()
        ontoggleHelp: (event, from, to, object) =>
          @helpEl.modal 'toggle'

  selectOutlet: (args...) -> @fsm.selectOutlet(args...)
  selectInlet:  (args...) -> @fsm.selectInlet(args...)

  _setActiveOutlet: (data) ->
    @activeOutlet?.el.remove()
    @activeOutlet = data

  _getActiveOutlet: -> @activeOutlet

  _setInlet: (data) ->
    outletData = do @_getActiveOutlet
    return if not outletData
    from = @objects.get outletData.modelID
    to   = @objects.get data.modelID
    # FIXME: if connected then disconnect?
    from.connect outletData.index, data.modelID, data.index
    @_setActiveOutlet undefined
}
