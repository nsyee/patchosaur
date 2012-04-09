# FIXME: require underscore
# FIXME: require jquery

patchagogy = @patchagogy = @patchagogy or {}

patchagogy.Object = Backbone.Model.extend {
  defaults:
    text: 'identity' # '' and even ' ' makes 0px objects
    numInlets: 3
    numOutlets: 2

  isBlank: -> @get('text') == 'identity'

  _textParse: (text) ->
    # split arguments, don't split between single quotes
    tokens = text.match /'[^']+'|\S+/g
    return [''] if tokens is null
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
    # FIXME: needs more, see trello...
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

  disconnectAll: ->
    @set 'connections', {}
    @trigger 'change:connections'

  clear: ->
    @disconnectAll()
    @view = null
  
  getToObjects: () ->
    # get a list of objects this is connected to
    # useful for limiting connection redraws
    _.flatten(
      for tos in _.values @get 'connections'
        for to in tos
          to[0])
}

patchagogy.Objects = Backbone.Collection.extend {
  initialize: ->
    @bind 'remove', (removed) ->
      _.each @connectedFrom(removed), (object) ->
        do object.disconnectAll

  # FIXME: you are going to need this
  #@bind 'change:numInlets change:numOutlets', (changed) =>
  # FIXME: do you need this? probably for changing numoutlets
  # connectedObjects: (targetObject) ->
  #   # get objects this is connected to or from
  #   # including this object
  #   tid = targetObject.id
  #   targetToObjects = do targetObject.getToObjects
  #   affected = @filter (object) ->
  #     toObjects = do object.getToObjects
  #     tid == object.id or tid in toObjects or tid in targetToObjects

  connectedFrom: (targetObject) ->
    # get objects this is connected from
    # INCLUDING this object
    tid = targetObject.id
    affected = @filter (object) ->
      toObjects = do object.getToObjects
      tid == object.id or tid in toObjects

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
