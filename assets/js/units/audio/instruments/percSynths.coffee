class BDSynth extends AudioletGroup
  @names = ['bdpercsynth~']
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

class SnareSynth extends AudioletGroup
  @names = ['snarepercsynth~']
  constructor: (audiolet, velocity) ->
    # FIXME: use velocity
    super audiolet, 0, 1
    a = audiolet
    @gain = new Gain a
    @noise = new WhiteNoise a
    @env = new PercussiveEnvelope a, 1, 0.005, 0.06, =>
      a.scheduler.addRelative 5, => do @remove
    @freq = new MulAdd a, 250
    @noise.connect @gain
    @env.connect @gain, 0, 1
    @gain.connect @outputs[0]

class ClosedHatSynth extends AudioletGroup
  @names = ['chpercsynth~']
  constructor: (audiolet, velocity) ->
    # FIXME: use velocity
    super audiolet, 0, 1
    a = audiolet
    @gain = new Gain a
    @noise = new WhiteNoise a
    @bpf = new BandPassFilter a, 8200 # FIXME: no bw?
    @env = new PercussiveEnvelope a, 1, 0.001, 0.02, =>
      a.scheduler.addRelative 5, => do @remove
    @freq = new MulAdd a, 250
    @noise.connect @bpf
    @bpf.connect @gain
    @env.connect @gain, 0, 1
    @gain.connect @outputs[0]

synths = [
  BDSynth
  SnareSynth
  ClosedHatSynth
]

for Synth in synths then do (Synth) ->
  class SynthWrapper extends patchosaur.Unit
    @names: Synth.names
    setup: (@objectModel) ->
      @objectModel.set numInlets: 1
      @objectModel.set numOutlets: 1
      a = patchosaur.audiolet
      oNode = new PassThroughNode a, 1, 1
      @audioletOutputNodes = [oNode]
      inlet = (velocity) ->
        synth = new Synth a, velocity
        synth.connect oNode
      @inlets = [inlet]

  patchosaur.units.add SynthWrapper
