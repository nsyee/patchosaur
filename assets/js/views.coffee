
patchagogy = @patchagogy = @patchagogy or {}

patchagogy.ObjectView = Backbone.View.extend {
  initialize: () ->
    # get elements inside a span or div?
    @p = patchagogy.paper
    @id = _.uniqueId 'objectView_'
    # FIXME: draws twice
    # @model.bind 'change', @render, @
    @connections = []
    # @model.bind 'change', @drawConnections, @
    @model.set 'view', @
    do @render
  drawConnections: (redraw=true) ->
    # try to move current connections
    if not redraw and not _.isEmpty @connections
      for connection in @connections
        @p.connection connection
      return
    # clear current
    for connection in @connections
      connection.line.remove()
      @connections = []
    connections = @model.get 'connections'
    for outlet of connections
      for to in connections[outlet]
        toID = to[0]
        inlet = to[1]
        toElem = patchagogy.patch.get toID
        @connections.push @p.connection @rect, toElem.get('view').rect, '#f00'
  render: () ->
    console.log 'rendering', @
    drawConnections = (redraw) => @drawConnections redraw
    model = @model # for raphael funcs
    p = @p
    x = @model.get 'x'
    y = @model.get 'y'
    text = @model.get 'text'
    set = @p.set()
    textElem = @p.text x, y, text
    box = textElem.getBBox()
    padding = 2
    rect = @p.rect box.x - 2, box.y - 2, box.width + 4, box.height + 4, 2
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
    # closed over textElem, model, p, rect
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
      # set these on model silently
      att = {x: @ox + dx, y: @oy + dy}
      @attr att
      # move text node
      textNode = textElem
      if textNode
        att = {x: textNode.ox + dx, y: textNode.oy + dy}
        textNode.attr att
      # FIXME: put this on view object, close over fat-arrowed
      drawConnections(false)
      p.safari()
    move = _.throttle move, 25
    rect.drag move, startDrag, endDrag
    drawConnections()
    @
}

patchagogy.PatchView = Backbone.View.extend {
  el: $('#holder')
  initialize: () ->
    @patch = @options.patch
    @patch.bind 'add', (object) ->
      console.log 'new view for', object
      new patchagogy.ObjectView model: object
    , @

    # connections.push(r.connection(shapes[0], shapes[1], "#f00"))
    # connections.push(r.connection(shapes[1], shapes[2], "#f00", "#f0f|5"))
    # connections.push(r.connection(shapes[1], shapes[3], "#f00", "#f0f"))
    @
    #see todo list app:
    #http://documentcloud.github.com/backbone/docs/todos.html
}
