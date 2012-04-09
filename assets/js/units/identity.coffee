identity = patchagogy.ExecClass.extend
  initialize:
    @get('options')
  id: 'identity'
  exec: (args...) ->
    for arg, i in args
      @outlet[i] arg
