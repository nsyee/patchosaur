patchagogy = @patchagogy = @patchagogy or {}

patchagogy.ObjectView = Backbone.View.extend {
  initialize: () ->
    # get elements inside a span or div?
    @p = patchagogy.paper
    @patchView = @options.patchView
    @id = _.uniqueId 'objectView_'
    @model.set 'view', @
    # bind events
    @model.bind 'remove', => do @clearElems
    @model.bind 'change:connections', => do @drawConnections
    @model.bind 'change:x change:y', => do @place
    # triggered by patch view when x or y change on any obj
    @bind 'redrawConnections', => do @drawConnections
    # when text changes, start over...
    @model.bind 'change:numInlets change:numOutlets change:text', =>
      console.log 'calling change text'
      do @clearElems
      do @render

    @connections = []
    @raphaelBox = null
    @raphaelText = null
    @inlets  = []
    @outlets = []
    # make it
    do @render
    @raphaelSet.forEach (el) =>
      el.node.setAttribute 'class', @id

  clearElems: ->
    for el in _.flatten [@raphaelSet, @raphaelBox, @raphaelText, @inlets, @outlets]
      el?.remove()

  clear: () ->
    patchagogy.objects.remove(@model)

  edit: () ->
    @raphaelSet.hide()
    editEl = $ document.createElement 'input'
    bbox = @raphaelBox.getBBox()
    $('body').append editEl
    editEl.focus()
    editEl.select() #FIXME
    editEl.css 'position', 'absolute'
    editEl.css 'left', bbox.x - 1
    editEl.css 'top', bbox.y - 1
    if not do @model.isBlank
      editEl.val @model.get 'text'
    editEl.on 'focusout', (event) =>
      @model.set 'text', editEl.val() or 'identity'
      editEl.remove()
      @raphaelSet.show()
    editEl.on 'keydown', (event) ->
      do editEl.blur if event.which == 13

  place: () ->
    x = @model.get 'x'
    y = @model.get 'y'
    for elem in _.flatten [@raphaelBox, @raphaelText, @inlets, @outlets]
      elem.attr
        x: x + (elem.offsetX or 0)
        y: y + (elem.offsetY or 0)
    #@p.safari()

  drawConnections: () ->
    # draw your own lines
    # FIXME, move current if poss
    # else, clear current and redo
    # FIXME there has to be some kind of wrapper lib
    # make slightly curvy?
    # http://raphaeljs.com/reference.html#Paper.path
    # still leaking memory, maybe this isn't why
    # but it's better anyway
    # FIXME: rename @connections to connectionels, update line instead of making new one
    for line in @connections
      line.remove()
    @connections = []
    connections = @model.get 'connections'
    for outlet of connections
      for to in connections[outlet]
        toID = to[0]
        inlet = to[1]
        toElem = patchagogy.objects.get(toID)?.get('view')?.inlets[inlet]
        if not toElem
          console.warn "no inlet here, we must be loading a patch"
          continue
        fromElem = @outlets[outlet]
        if not fromElem
          # num outlets not set yet, we're still on default 1
          console.warn "no outlet here, we must be loading a patch"
          continue
        bbox1 = fromElem.getBBox()
        x1 = bbox1.x + (bbox1.width / 2)
        y1 = bbox1.y + (bbox1.height)
        # FIXME
        bbox2 = toElem.getBBox()
        x2 = bbox2.x + (bbox2.width / 2)
        y2 = bbox2.y
        conn = @p.path "#M#{x1},#{y1}L#{x2},#{y2}"
        @connections.push conn
        # FIXME: necc?
        # @raphaelSet.push conn

  _setOffset: (onEl, fromEl) ->
    onEl.offsetX = onEl.attrs.x - fromEl.attrs.x
    onEl.offsetY = onEl.attrs.y - fromEl.attrs.y

  render: () ->
    @raphaelSet?.remove()
    do @p.setStart
    console.log 'rendering object view', @id, @, @model
    drawConnections = => do @drawConnections
    p = @p
    x = @model.get 'x'
    y = @model.get 'y'
    text = @model.get 'text'
    textElem = @p.text x, y, text
    textElem.attr
      "font-size": 11
      "font-family": "monospace"
    box = textElem.getBBox()
    # reposition so saves/restores work
    # FIXME this is stupid
    textElem.attr
      x: x + (box.width / 2)
      y: y + (box.height / 2)
    box = textElem.getBBox()
    @raphaelText = textElem
    pad = 2
    rect = @p.rect box.x - pad, box.y - pad + 1, box.width + (pad*2), box.height + (pad*2) - 1, 2
    @raphaelBox = rect
    @rect = rect
    # @_setOffset @raphaelText, @raphaelBox
    @_setOffset @raphaelText, @raphaelBox

    rect.attr
      fill: '#a00'
      stroke: '#e03'
      "fill-opacity": 0
      "stroke-width": 2
      cursor: "move"
    # make inlets and outlets
    # FIXME: this is the same code twice. clean up.
    # also pull it out so you can redraw them on model:numInlets change
    inlet.remove() for inlet in @inlets
    outlet.remove() for outlet in @outlets
    @inlets = []
    @outlets = []
    numInlets = @model.get 'numInlets'
    numOutlets = @model.get 'numOutlets'
    padding = 5
    width = box.width - (padding * 2)
    # FIXME ugly
    spacing = width / ((numInlets - 1) or 2)
    for inlet in _.range numInlets
      inletElem = @p.rect(
        box.x + padding - 3 + (inlet * spacing),
        box.y - 6,
        6, 4, 1)
      @_setOffset inletElem, rect
      inletElem.attr fill: '#9b9'
      @inlets.push inletElem
    spacing = width / ((numOutlets - 1) or 2)
    for outlet in _.range numOutlets
      outletElem = @p.rect(
        box.x + padding - 3 + (outlet * spacing),
        box.height + box.y + 2,
        6, 4, 1)
      @_setOffset outletElem, rect
      outletElem.attr fill: '#99f'
      @outlets.push outletElem

    # FIXME: set on the view or model?
    # i think on the patch view
    # activeOutlet, on inlet clicks
    # if there's an active outlet, tell model about connection
    _.each @outlets, (outlet, i) =>
      outlet.click (event) =>
        glowee = outlet.glow()
        anim = Raphael.animation {"stroke-width": 12}, 400
        anim = anim.repeat Infinity
        glowee.animate anim
        @patchView.selectOutlet
          modelID: @model.id
          index: i
          el: glowee

    _.each @inlets, (inlet, i) =>
      inlet.click (event) =>
        @patchView.selectInlet
          modelID: @model.id
          index: i

    # FIXME:  delegate
    # glow on hover, set this up as delegate
    _.each _.flatten([@outlets, @inlets]), (xlet) ->
      xlet.hover (event) ->
        xlet.glowEl = xlet.glow()
      , (event) ->
        xlet.glowEl.remove()

    # set up dragging behavior
    self = @
    startDrag = ->
      @ox = @attr 'x'
      @oy = @attr 'y'
      @animate({"fill-opacity": .3}, 200)
    endDrag = (event) ->
      @animate({"fill-opacity": 0}, 700)
    move = (dx, dy) ->
      att = {x: @ox + dx, y: @oy + dy}
      # set on model, triggers events to redraw
      self.model.set att
    move = _.throttle move, 22
    rect.drag move, startDrag, endDrag
    rect.dblclick => do @edit
    drawConnections()
    rect.click (event) =>
      if event.altKey or event.ctrlKey
        do @clear
    @raphaelSet = do @p.setFinish
}

patchagogy.PatchView = Backbone.View.extend {
  el: $('#holder')
  initialize: () ->
    @objects = @options.objects
    @svgEl = @$el.children('svg').get 0
    @currentObjectView
    @fsm = do @makeFSM
    # bind model change events
    @objects.bind 'add', (object) =>
      objectView = new patchagogy.ObjectView
        model: object
        patchView: @
      do objectView.edit if do object.isBlank

    @objects.bind 'add change:x change:y change:text', (changedObject) =>
      affected = @objects.connectedFrom changedObject
      _.each affected, (object) ->
        object.get('view').trigger 'redrawConnections'

    # bind view event handlers
    @$el.on 'dblclick', (event) =>
      if not (event.target == @svgEl)
        return
      @fsm.createObject
        x: event.pageX
        y: event.pageY

  makeFSM: () ->
    # https://github.com/jakesgordon/javascript-state-machine
    @fsm = StateMachine.create
      initial: 'ready'
      events: [
        {name: 'selectOutlet', from: '*', to: 'outletSelected'}
        {name: 'selectInlet', from: 'outletSelected', to: 'ready'}
        {name: 'createObject', from: '*', to: 'editingObject'}
        {name: 'saveObjectEdit', from: 'editingObject', to: 'ready'}
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

  selectOutlet: (args...) -> @fsm.selectOutlet(args...)
  selectInlet:  (args...) -> @fsm.selectInlet(args...)

  _setActiveOutlet: (data) ->
    @activeOutlet?.el.remove()
    @activeOutlet = data

  _getActiveOutlet: -> @activeOutlet

  _setInlet: (data) ->
    outletData = do @_getActiveOutlet
    return if not outletData
    from = patchagogy.objects.get outletData.modelID
    to   = patchagogy.objects.get data.modelID
    # FIXME: if connected then disconnect?
    from.connect outletData.index, data.modelID, data.index
    @_setActiveOutlet undefined
}
