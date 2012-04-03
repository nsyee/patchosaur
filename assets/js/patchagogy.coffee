#= require 3p/jquery
#= require 3p/bootstrap
#= require 3p/underscore
#= require 3p/raphael
#= require 3p/backbone
#= require 3p/audiolet
#= require draw/connection
#= require models
#= require views
#= require controllers

console.log 'aww... shit.'

newID = do ->
  currID = 0
  ->
    newID = currID + 1
    currID = newID

# rectID: textElem
textNodes = {}

$ ->
  startDrag = ->
    @ox = @attr 'x'
    @oy = @attr 'y'
    textNode = textNodes[@node.id]
    if textNode
      textNode.ox = textNode.attr 'x'
      textNode.oy = textNode.attr 'y'
    @animate({"fill-opacity": .3}, 200)

  endDrag = ->
    @animate({"fill-opacity": 0}, 700)

  move = (dx, dy) ->
    att = {x: @ox + dx, y: @oy + dy}
    @attr att
    # move text node
    textNode = textNodes[@node.id]
    if textNode
      att = {x: textNode.ox + dx, y: textNode.oy + dy}
      textNode.attr att
    for c in connections
      r.connection(c)
    r.safari()

  r = Raphael("holder", "100%", "100%")

  connections = []

  createNode = (x, y, text) ->
    set = r.set()
    textElem = r.text x, y, text
    box = textElem.getBBox()
    padding = 2
    rect = r.rect box.x - 2, box.y - 2, box.width + 4, box.height + 4, 2
    rect.node.id = do newID
    textNodes[rect.node.id] = textElem
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
    rect.drag move, startDrag, endDrag

  createNode 250, 250, 'hey there'

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


$ ->
  # start the engines
  appController = new patchagogy.controllers.App
  do Backbone.history.start
