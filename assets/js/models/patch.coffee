# FIXME: require underscore
# FIXME: require jquery

patchagogy = @patchagogy = @patchagogy or {}

patchagogy.Object = Backbone.Model.extend {
  defaults: # should be func?
    text: ''
    numInlets: 2
    numOutlets: 2
    connections: {} # FIXME: structure?
    raphaelBox: null # view

  _textParse: (text) ->
    # split arguments, don't split between single quotes
    tokens = text.match /'[^']+'|\S+/g
    # convert to native types where possible
    for token in tokens
      # strip leading and trailing single quotes
      token = token.replace /^'|'$/g, ''
      try
        JSON.parse(token)
      catch error
        token

  initialize: ->
    @id = _.uniqueId('object_')
    parsedText = @_textParse @get 'text'
    @set 'object_class', parsedText[0]
    @set 'object_args', parsedText[1..]
    console.debug "creating object:", @get('object_class'), \
      @get('object_args')
    # create view, assign reference
    @set 'raphaelBox', null
    @bind 'change:text', ->
    @bind 'change:connections', ->

  connect: (outIndex, inObjectID, inIndex) ->
    cxs = @get('connections')
    cxs[outIndex] ?= []
    to = [inObjectID, inIndex]
    # if it's already connected don't bother
    return if _.find cxs[outIndex], (cx) -> _.isEqual cx, to
    # connect
    cxs[outIndex].push to
    cxs = @set('connections')

  disconnect: (outIndex, inObjectID, inIndex) ->
    cxs = @get('connections')
    cxs = _.reject cxs, (cx) ->
        _.isEqual cx, [inObjectID, inIndex]
    cxs = @set('connections')
}

patchagogy.Patch = Backbone.Collection.extend {
  # url: -> '/patch'
  model: patchagogy.Object

  newObject: (attrs) ->
    @add attrs
}

$ ->
  patchagogy.patch = new patchagogy.Patch
  console.log 'creating patch:', patchagogy.patch
  # keep these test cases around
  x = patchagogy.patch.newObject {text: 'hey'}
  x = patchagogy.patch.newObject {text: "hey2 1.0 987 'hey there'"}
  x = patchagogy.patch.newObject {text: "hey3 3 '[1, 23, 8]' '{\"2\": 3}'"}
