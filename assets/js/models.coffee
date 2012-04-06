# FIXME: require underscore
# FIXME: require jquery

patchagogy = @patchagogy = @patchagogy or {}

patchagogy.Object = Backbone.Model.extend {
  defaults: # should be func?
    text: ''
    numInlets: 3
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

  toJSON: ->
    # whitelist only attributes to sync
    o = {}
    for prop in ['x', 'y', 'text']
      o[prop] = @get prop
    return o

  initialize: ->
    @id = _.uniqueId('object_')
    parsedText = @_textParse @get 'text'
    @set 'object_class', parsedText[0]
    @set 'object_args', parsedText[1..]
    console.debug "creating object:", @get('object_class'), \
      @get('object_args')
    # create view, assign reference
    @set 'raphaelBox', null
    @set 'connections', {}
    @bind 'change:text', ->
    @bind 'change:connections', ->

  connect: (outIndex, inObjectID, inIndex) ->
    cxs = @get 'connections'
    cxs[outIndex] ?= []
    to = [inObjectID, inIndex]
    # if it's already connected don't bother
    return if _.find cxs[outIndex], (cx) -> _.isEqual cx, to
    # connect
    cxs[outIndex].push to
    cxs = @set 'connections', cxs
    # FIXME: backbone doesn't like prop to be object, change doesn't fire
    # fire it yourself
    @trigger 'change:connections'

  disconnect: (outIndex, inObjectID, inIndex) ->
    cxs = @get('connections')
    cxs = _.reject cxs, (cx) ->
        _.isEqual cx, [inObjectID, inIndex]
    cxs = @set('connections', cxs)
    @trigger 'change:connections'
  
  getToObjects: () ->
    # get a list of objects this is connected to
    # useful for limiting connection redraws
    _.flatten(
      for tos in _.values @get 'connections'
        for to in tos
          to[0])
}

patchagogy.Objects = Backbone.Collection.extend {
  model: patchagogy.Object
  newObject: (attrs) ->
    object = new @model attrs
    @add object
    object
}

# backbone collections don't have a save method, wrap in Model
patchagogy.Patch = Backbone.Model.extend
  url: '/patch'
  defaults:
    objects: []
