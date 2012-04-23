class BDSynth extends AudioletGroup
  constructor: (audiolet, velocity) ->
    # FIXME: use velocity
    super audiolet, 0, 1 # group numInputs, numOutputs
    a = audiolet
    @gain = new Gain a
    @sin = new Sine a
    @env = new PercussiveEnvelope a, 1, 0.0005, 0.05, =>
      # FIXME: why does 0 not work when caller is audiolet.scheduler?
      a.scheduler.addRelative 5, => do @remove
    @freq = new MulAdd a, 250
    @env.connect @freq
    @freq.connect @sin
    @sin.connect @gain
    @env.connect @gain, 0, 1
    @gain.connect @outputs[0]

class BD extends patchosaur.Unit
  @names: ['bdpercsynth~']
  setup: (@objectModel) ->
    @objectModel.set numInlets: 1
    @objectModel.set numOutlets: 1
    a = patchosaur.audiolet
    oNode = new PassThroughNode a, 1, 1
    @audioletOutputNodes = [oNode]
    inlet = (velocity) ->
      synth = new BDSynth a, velocity
      synth.connect oNode
    @inlets = [inlet]

patchosaur.units.add BD
