
patchagogy = @patchagogy = @patchagogy or {}

patchagogy.ObjectView = Backbone.View.extend {
  initialize: () ->
    # get elements inside a span or div?
    @p = patchagogy.paper
    @id = _.uniqueId 'objectView_'
    @model.set 'view', @
    # bind events
    @model.bind 'change:connections', => @drawConnections true
    @model.bind 'change:x change:y', => do @place
    # triggered by patch view when x or y change on any obj
    @bind 'redrawConnections', => @drawConnections false

    @connections = []
    @raphaelBox = null
    @raphaelText = null
    @textOffset = [0, 0]
    # make it
    do @render

  place: () ->
    x = @model.get 'x'
    y = @model.get 'y'
    @raphaelBox.attr x: x, y: y
    @raphaelText.attr
      x: x + @textOffset[0]
      y: y + @textOffset[1]
    @p.safari()

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
    @raphaelBox?.remove()
    @raphaelText?.remove()
    drawConnections = (redraw) => @drawConnections redraw
    p = @p
    x = @model.get 'x'
    y = @model.get 'y'
    text = @model.get 'text'
    textElem = @p.text x, y, text
    @raphaelText = textElem
    box = textElem.getBBox()
    padding = 2
    rect = @p.rect box.x - 2, box.y - 2, box.width + 4, box.height + 4, 2
    @raphaelBox = rect
    @rect = rect
    @textOffset = [
      @raphaelText.attrs.x - @raphaelBox.attrs.x
      @raphaelText.attrs.y - @raphaelBox.attrs.y
    ]

    rect.node.id = @id
    rect.attr {
      fill: '#a00'
      stroke: '#e03'
      "fill-opacity": 0
      "stroke-width": 2
      cursor: "move"
    }
    # set up dragging behavior
    self = @
    startDrag = ->
      @ox = @attr 'x'
      @oy = @attr 'y'
      rt = self.raphaelText
      rt.ox = rt.attr 'x'
      rt.oy = rt.attr 'y'
      @animate({"fill-opacity": .3}, 200)
    endDrag = ->
      @animate({"fill-opacity": 0}, 700)
    move = (dx, dy) ->
      att = {x: @ox + dx, y: @oy + dy}
      # set on model, triggers events to redraw
      self.model.set att
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
