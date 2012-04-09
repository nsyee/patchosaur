patchagogy = @patchagogy = @patchagogy or {}
patchagogy.units ?= {}

# FIXME: do you want each inlet to have a func, or one func for all? both?
# both.
# nah, maybe just inlet and outlet calls
#
# are these, models, views, what's what.

class patchagogy.Unit
  constructor: (@objectModel) ->
    console.log 'calling inialiaze on Unit', @
    @objectModel.set 'numInlets', 4
    @objectModel.set 'numOutlets', 5

  out: (i, stuff) ->


