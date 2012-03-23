patchagogy = @patchagogy = @patchagogy or {}

patchagogy.Node = Backbone.Model.extend {
  defaults:
    object: null
    index: 0
    connections: []

  to: (node) ->
    connections = @get 'connections'
    connections.push node
    @set connections: connections
  from: (node) ->
    node.to @
  chain: (node) ->
    @.to node
    node

  # FIXME
  getEdges: ->
}

patchagogy.Object = Backbone.Model.extend {
  defaults: # should be func?
    text: ''
    nodes: [] # inlets and outlets
    raphaelBox: null

  initialize: ->
    console.log "initializing object #{JSON.stringify @}"
    @bind 'change:text', ->
      # do some audio stuff
      #

  getNode: (index) =>
    nodes = @get 'nodes'
    if not nodes[index]?
      nodes[index] ?= new patchagogy.Node {
        object: @
        index: index }
      @set nodes: nodes
    nodes[index]
  at: @getNode

  connect: (outIndex, inObject, inIndex) ->
    @at(outIndex).to inObject.at inIndex
}

patchagogy.Patch = Backbone.Collection.extend {
  # url: -> '/patch'
  model: patchagogy.Object

  newObject: (attrs) ->
    @add attrs
}

$ ->
  patchagogy.patch = new patchagogy.Patch
  x = patchagogy.patch.newObject {text: 'hey'}
