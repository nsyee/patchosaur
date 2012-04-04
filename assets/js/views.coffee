
patchagogy = @patchagogy = @patchagogy or {}

patchagogy.ObjectView = Backbone.View.extend {
  initialize: () ->
    # get elements inside a span or div?
    @p = patchagogy.paper
    @id = _.uniqueId 'objectView_'
    @connections = []
    @raphaelElems = []
    @model.bind 'change:connections', => @drawConnections true
    @bind 'redrawConnections', => @drawConnections false
    @model.set 'view', @
    do @render

  drawConnections: (redraw=true) ->
    # try to move current connections
    if not redraw and not _.isEmpty @connections
      for connection in @connections
        @p.connection connection
      return
    # else, clear current and redo
    for connection in @connections
      connection.line.remove()
    @connections = []
    connections = @model.get 'connections'
    # console.log @model.get('text'), connections
    for outlet of connections
      for to in connections[outlet]
        toID = to[0]
        inlet = to[1]
        toElem = patchagogy.patch.get toID
        @connections.push @p.connection @rect, toElem.get('view').rect, '#f00'
  render: () ->
    console.log 'rendering', @
    for elem in @raphaelElems
      elem.remove()
    @raphaelElems = []
    drawConnections = (redraw) => @drawConnections redraw
    model = @model # for raphael funcs
    p = @p
    x = @model.get 'x'
    y = @model.get 'y'
    text = @model.get 'text'
    set = @p.set()
    textElem = @p.text x, y, text
    @raphaelElems.push textElem
    box = textElem.getBBox()
    padding = 2
    rect = @p.rect box.x - 2, box.y - 2, box.width + 4, box.height + 4, 2
    @raphaelElems.push rect
    @rect = rect
    rect.node.id = @id
    rect.attr {
      fill: '#a00'
      stroke: '#e03'
      "fill-opacity": 0
      "stroke-width": 2
      cursor: "move"
    }
    # make a set, add text, rect to fit
    # set attrs on rect
    set.push rect
    set.push textElem
    # set up dragging behavior
    # closed over textElem, model, p, rect, view
    startDrag = ->
      @ox = @attr 'x'
      @oy = @attr 'y'
      textNode = textElem
      if textNode
        textNode.ox = textNode.attr 'x'
        textNode.oy = textNode.attr 'y'
      @animate({"fill-opacity": .3}, 200)
    endDrag = ->
      @animate({"fill-opacity": 0}, 700)
    move = (dx, dy) ->
      att = {x: @ox + dx, y: @oy + dy}
      # move raphael object
      # FIXME: don't do this, the view should
      # be listening for model changes and 
      # moving the objects
      @attr att
      # set on model, redraws connections
      model.set att
      # move text node
      textNode = textElem
      if textNode
        att = {x: textNode.ox + dx, y: textNode.oy + dy}
        textNode.attr att
      p.safari()
    move = _.throttle move, 22
    rect.drag move, startDrag, endDrag
    drawConnections()
    @
}

patchagogy.PatchView = Backbone.View.extend {
  el: $('#holder')
  initialize: () ->
    @patch = @options.patch
    @svgEl = @$el.children('svg').get(0)
    @objectViews = []
    @patch.bind 'add', (object) =>
      console.log 'new view for', object
      @objectViews.push new patchagogy.ObjectView model: object
    , @
    redrawAllConnections = () =>
      # FIXME: only redraw connections on affected lines
      for object in @objectViews
        object.trigger('redrawConnections')
    @patch.bind 'change:x change:y', redrawAllConnections

    # set up creating new 
    # objects with ctrl click
    @$el.on 'click', (event) =>
      if event.target == @svgEl and event.ctrlKey
        x = event.pageX
        y = event.pageY
        @patch.newObject
          x: event.pageX
          y: event.pageY
          text: 'omg i added this'

        # FIXME create a new elem
    @
}
