# FIXME: require underscore
# FIXME: require jquery

patchagogy = @patchagogy = @patchagogy or {}

DEFAULT_UNIT = 'identity'

patchagogy.Object = Backbone.Model.extend {
  defaults:
    text: DEFAULT_UNIT # '' and even ' ' makes 0px objects
    numInlets: 3
    numOutlets: 2

  isBlank: -> @get('text') == DEFAULT_UNIT

  toJSON: ->
    # whitelist only attributes to sync
    # FIXME: needs more, see trello...
    o = {}
    for prop in ['x', 'y', 'text']
      o[prop] = @get prop
    return o

  initialize: ->
    @id = _.uniqueId('object_')
    @set 'connections', {}
    do @setup

  setup: ->
    parsedText = @_textParse @get 'text'
    @set unitClassName: parsedText[0]
    @set unitArgs: parsedText[1]
    console.debug "setting up object:", @get('unitClassName'), \
      @get('unitArgs')
    # put this in private method, call on change:text?
    UnitClass = patchagogy.units[@get 'unitClassName']
    if not UnitClass
      console.warn "no unit class found for #{@get 'unitClassName'}, using #{DEFAULT_UNIT}"
      UnitClass = patchagogy.units[DEFAULT_UNIT]
    @set unit: new UnitClass(@, @get 'unitArgs')
    @bind 'change:text', =>
      do @setup

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

  disconnect: (outIndex, inObjectID, inIndex) ->
    cxs = @get('connections')
    cxs = _.reject cxs, (cx) ->
        _.isEqual cx, [inObjectID, inIndex]
    cxs = @set('connections', cxs)
    @trigger 'change:connections', @

  disconnectAll: ->
    @set 'connections', {}
    @trigger 'change:connections', @

  clear: ->
    console.log 'clearing model', @
    @disconnectAll()
    # @unset 'view'
  
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
