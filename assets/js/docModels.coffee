# FIXME: require underscore
# FIXME: require jquery

patchagogy = @patchagogy = @patchagogy or {}

DEFAULT_UNIT = 'identity'

patchagogy.Object = Backbone.Model.extend {
  defaults:
    text: DEFAULT_UNIT # '' and even ' ' makes 0px objects FIXME: just put in min width
    numInlets: 1
    numOutlets: 1
    x: 100
    y: 100

  isBlank: -> @get('text') == DEFAULT_UNIT

  toJSON: ->
    # whitelist only attributes to sync
    # FIXME: needs more, see trello...
    o = {}
    for prop in ['x', 'y', 'text', 'connections']
      o[prop] = @get prop
    o.id = @id
    return o

  initialize: ->
    @get('connections') or @set 'connections', {}
    do @setup
    @bind 'remove', => do @disconnectAll
    @bind 'change:text', =>
      do @setup

  setup: ->
    parsedText = @_textParse @get 'text'
    @set unitClassName: parsedText[0]
    @set unitArgs: parsedText[1]
    console.debug "setting up object:", @get('unitClassName'), \
      @get('unitArgs')

  _textParse: (text) ->
    # returns [execClass, options]
    # everything before first space
    execClass = text.replace(/\ .*/, '')
    # everything after first space, surrounded
    # by square brackets and parsed as json
    options = text.replace(/^.*?\ /g, '')
    try
      options = JSON.parse("[#{options}]")
    catch error
      console.warn "json parsing of object '#{execClass}' options '#{options}' failed:", error, "...using options string"
    finally
      return [execClass, options]

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
    @trigger 'change:connections', @
    @

  connected: (outIndex, inObjectID, inIndex) ->
    # are two objects connected?
    cxs = @get 'connections'
    return false unless cxs[outIndex]
    to = [inObjectID, inIndex]
    connection = _.find cxs[outIndex], (cx) -> _.isEqual cx, to
    connection and true or false

  disconnect: (outIndex, inObjectID, inIndex) ->
    # FIXME test
    cxs = @get('connections')
    cxs[outIndex] = _.reject cxs[outIndex], (cx) ->
        _.isEqual cx, [inObjectID, inIndex]
    @set('connections', cxs)
    @trigger 'change:connections', @
    @

  disconnectTo: (inObjectID) ->
    # disconnect from this to another objectID
    # any outlet here, any outlet there.
    outlets = @get('connections')
    for outlet in _.keys outlets
      outlets[outlet] = _.reject outlets[outlet], (cx) ->
        _.isEqual cx[0], inObjectID
    @set('connections', outlets)
    @trigger 'change:connections', @
    @

  disconnectAll: ->
    @set 'connections', {}
    @trigger 'change:connections', @
    @

  getToObjectIDs: () ->
    # get a list of objects this is connected to
    # useful for limiting connection redraws
    _.flatten(
      for tos in _.values @get 'connections'
        for to in tos
          to[0])
}

patchagogy.Objects = Backbone.Collection.extend {
  url: '/patch'
  model: patchagogy.Object

  initialize: ->
    @bind 'remove', (removed) ->
      _.each @connectedFrom(removed), (object) ->
        object.disconnectTo removed.id
    @bind 'change', => do @save

  newObject: (attrs) ->
    attrs = {} if attrs is undefined
    if not attrs.id?
      # unique, using generated cid as id can collide
      # with old ones we loaded
      genID = -> _.uniqueId 'object_'
      id = do genID
      while @get id   # collision?
        id = do genID
      attrs.id = id
    object = new @model attrs
    @add object
    object

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
      toObjects = do object.getToObjectIDs
      tid == object.id or tid in toObjects

  # FIXME, save works, reload doesn't load connections
  # because connectinos aren't shallow. You could get rid of the trigger crap
  # if you fixed that. make them shallow.
  save: _.debounce () ->
    Backbone.sync 'create', @
  , 1000 # debounce ms

  clear: -> @remove @models

  load: () ->
    do @clear
    @fetch({add: true})
}
