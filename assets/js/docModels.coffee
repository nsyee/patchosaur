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
    @get('connections') or @setConnections []
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
    if text.match(/\ /g) # if space, pull out everything after it
      options = text.replace(/^.*?\ /g, '')
    else
      options = ''
    try
      options = JSON.parse("[#{options}]")
    catch error
      console.warn "json parsing of object '#{execClass}' options '#{options}' failed:", error, "...using options string"
    finally
      return [execClass, options]

  # backbone change events won't fire properly with
  # array attributes. flatten to a string until you
  # find a better way to do this
  setConnections: (connections) ->
    @set connections: JSON.stringify connections
  getConnections: ->
    JSON.parse @get 'connections'
  getPreviousConnections: ->
    JSON.parse @previous 'connections'

  connect: (outIndex, inObjectID, inIndex) ->
    connections = do @getConnections
    connection = [@id, outIndex, inObjectID, inIndex]
    connections.push connection
    connections = _.uniq connections, null, (x) -> x.join()
    @setConnections connections

  connected: (outIndex, inObjectID, inIndex) ->
    connections = do @getConnections
    match = [@id, outIndex, inObjectID, inIndex]
    !! _.find connections, (cx) -> _.isEqual match, cx

  disconnect: (outIndex, inObjectID, inIndex) ->
    connections = do @getConnections
    connection = [@id, outIndex, inObjectID, inIndex]
    connections = _.reject connections, (cx) -> _.isEqual cx, connection
    @setConnections connections

  disconnectTo: (inObjectID) ->
    # disconnect all connections from this to another objectID
    # any outlet here, any outlet there.
    connections = do @getConnections
    connections = _.reject connections, (cx) ->
      cx[2] == inObjectID
    @setConnections connections

  disconnectAll: -> @setConnections []

  getToObjectIDs: () ->
    # get a list of objects this is connected to
    # useful for limiting connection redraws
    (cx[2] for cx in do @getConnections)
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

  save: _.debounce () ->
    Backbone.sync 'create', @
  , 1000 # debounce ms

  clear: -> @remove @models

  load: () ->
    do @clear
    @fetch({add: true})
}
