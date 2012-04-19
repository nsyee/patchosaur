wrappedClasses = []
wrappedClasses.push _.extend MulAdd, names: ['muladd~']
wrappedClasses.push _.extend Sine, names: ['cycle~']
wrappedClasses.push _.extend Lag, names: ['lag~']
wrappedClasses.push _.extend Tanh, names: ['tanh~']

# wrap each audiolet "class" in a Unit
for AudioletClass in wrappedClasses then do (AudioletClass) ->
  class WrappedClass extends patchosaur.Unit
    @names: AudioletClass.names
    setup: (@objectModel) ->
      args = @objectModel.get 'unitArgs'
      a = patchosaur.audiolet
      @mainNode = new AudioletClass a, args...
      numInlets = @mainNode.numberOfInputs
      numOutlets = @mainNode.numberOfOutputs
      @objectModel.set {numInlets}
      @objectModel.set {numOutlets}
      # create pass through nodes that connect
      # to inputs and outputs of mainNode
      @audioletInputNodes = for i in _.range numInlets
        # close over i?
        inlet = new PassThroughNode a, 1, 1
        inlet.connect @mainNode, 0, i
        inlet
      @audioletOutputNodes = for i in _.range numOutlets
        outlet = new PassThroughNode a, 1, 1
        @mainNode.connect outlet, i, 0
        outlet
      # default inlets do nothing
      @inlets = ((->) for i in _.range(numInlets))
      # find AudioletParameters, set function inlets
      # to do setValue on them
      for prop, val of @mainNode then do (prop, val) =>
        if val?.input?.index? # is this an AudioletParameter?
          window.x = val
          @inlets[val.input.index] = (x) ->
            val.setValue x

  patchosaur.units.add WrappedClass
