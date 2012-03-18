#= require 3p/jquery
#= require 3p/bootstrap
#= require 3p/underscore
#= require 3p/raphael
#= require 3p/backbone
#= require 3p/audiolet
#= require draw/connection

console.log 'damn'

$ ->
  startDrag = ->
    if @type == 'rect'
      @ox = @attr 'x'
      @oy = @attr 'y'
    else
      @ox = @attr 'cx'
      @oy = @attr 'cy'
    @animate({"fill-opacity": .3}, 200)

  endDrag = ->
    @animate({"fill-opacity": 0}, 700)

  move = (dx, dy) ->
    if @type == 'rect'
      att = {x: @ox + dx, y: @oy + dy}
    else
      att = {cx: @ox + dx, cy: @oy + dy}
    @attr(att)
    for c in connections
      r.connection(c)
    r.safari()


  r = Raphael("holder", "100%", "100%")

  connections = []

  createNode = (text, x, y) ->
    group = do paper.set
    
    rect = r.rect x, y, 100, 20, 2
    rect.attr {
      fill: color
      stroke: color
      "fill-opacity": 0
      "stroke-width": 2
      cursor: "move"
    }
    # make a set, add text, rect to fit
    # set attrs on rect
    group.push rect
    group.drag move, startDrag, endDrag

  shapes = [  r.ellipse(190, 100, 30, 20),
              r.rect(290, 80, 60, 40, 10),
              r.rect(290, 180, 60, 40, 2),
              r.ellipse(450, 100, 20, 20)
  ]

  for shape in shapes
    # use getbbbox to make box same size as text
    # http://stackoverflow.com/questions/3142007/how-to-either-determine-svg-text-box-width-or-force-line-breaks-after-x-chara
    # set so they move together
    # http://stackoverflow.com/questions/1458095/using-raphael-js-to-create-text-nodes
    color = Raphael.getColor()
    shape.attr({fill: color, stroke: color, "fill-opacity": 0, "stroke-width": 2, cursor: "move"})
    shape.drag(move, startDrag, endDrag)

  connections.push(r.connection(shapes[0], shapes[1], "#f00"))
  connections.push(r.connection(shapes[1], shapes[2], "#f00", "#f0f|5"))
  connections.push(r.connection(shapes[1], shapes[3], "#f00", "#f0f"))
