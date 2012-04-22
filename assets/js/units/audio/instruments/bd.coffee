class BD extends patchosaur.Unit
  @names: ['bd~']
  setup: (@objectModel) ->
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    a = patchosaur.audiolet
    oNode = new PassThroughNode a, 1, 1
    @audioletOutputNodes = [oNode]
    inlet = (velocity) =>
      gain = new Gain a
      sin = new Sine a
      env = new PercussiveEnvelope a, 1, 0.001, 0.2, ->
        # FIXME: clicks! # doesn't look like we leak memory though. watch timeline
        # for node in [gain, sin]
        #   node.remove()
        # FIXME: see audiolet docs, make this into a synth: class bdsynth extends audioletgroup
        # FIXME: idea: when text empty on edit(), just remove the model
      freq = new MulAdd a, 290
      env.connect freq, 0, 0
      freq.connect sin, 0, 0
      sin.connect gain, 0, 0
      env.connect gain, 0, 1
      gain.connect oNode
    @inlets = [inlet]

patchosaur.units.add BD
