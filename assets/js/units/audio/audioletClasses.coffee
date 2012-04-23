# see http://oampo.github.com/Audiolet/api.html

wrappedClasses = [
  # save name Sine for actual sin() one, not table based
  _.extend Sine, names: ['cycle~']
  _.extend Triangle, names: ['triangle~']
  _.extend Saw, names: ['saw~']
  _.extend Square, names: ['square~']
  _.extend Pulse, names: ['pulse~']
  _.extend WhiteNoise, names: ['noise~']
  _.extend Envelope, names: ['envelope~']
  _.extend ADSREnvelope, names: ['adsr~']
  _.extend PercussiveEnvelope, names: ['perc~']
  # FIXME: this isn't going to work, look into args:
  # http://oampo.github.com/Audiolet/api.html
  _.extend BufferPlayer, names: ['bufferplayer~']
  _.extend Gain, names: ['gain~']
  _.extend Pan, names: ['pan~']
  _.extend UpMixer, names: ['upmixer~']
  _.extend CrossFade, names: ['xfade~']
  _.extend LinearCrossFade, names: ['linerxfade~']
  _.extend Limiter, names: ['limiter~']
  _.extend BiquadFilter, names: ['biquad~']
  _.extend LowPassFilter, names: ['lpf~']
  _.extend HighPassFilter, names: ['hpf~']
  # FIXME: no bandiwdth?
  _.extend BandPassFilter, names: ['bpf~']
  _.extend BandRejectFilter, names: ['brf~']
  _.extend AllPassFilter, names: ['apf~']
  _.extend DCFilter, names: ['dcblock~']
  _.extend Lag, names: ['lag~']
  _.extend Delay, names: ['delay~']
  _.extend FeedbackDelay, names: ['fbdelay~']
  _.extend CombFilter, names: ['comb~']
  _.extend DampedCombFilter, names: ['dampcomb~']
  _.extend Reverb, names: ['reverb~']
  _.extend ReverbB, names: ['reverbb~']
  _.extend SoftClip, names: ['softclip~']
  _.extend BitCrusher, names: ['bitcrusher~']
  _.extend Amplitude, names: ['amp~']
  # FIXME: these work with callbacks, won't work
  _.extend DiscontinuityDetector, names: ['discontinuity~']
  _.extend BadValueDetector, names: ['badvalue~']
  _.extend TriggerControl, names: ['triggercontrol~']
  _.extend Add, names: ['add~', '+~']
  _.extend Subtract, names: ['subtract~', '-~']
  _.extend Multiply, names: ['multiply~', '*~']
  _.extend Divide, names: ['divide~', '/~']
  _.extend Modulo, names: ['modulo~', '%~']
  _.extend Reciprocal, names: ['reciprocal~']
  _.extend MulAdd, names: ['muladd~', '*+~']
  _.extend Tanh, names: ['tanh~']
]

# wrap each audiolet "class" in a Unit
for AudioletClass in wrappedClasses then do (AudioletClass) ->
  class WrappedClass extends patchosaur.Unit
    @names: AudioletClass.names
    @help: "wrapped from audiolet: see http://oampo.github.com/Audiolet/api.html"
    setup: (@objectModel) ->
      args = @objectModel.get 'unitArgs'
      a = patchosaur.audiolet
      @mainNode = new AudioletClass a, args...
      numInlets = @mainNode.numberOfInputs
      numOutlets = @mainNode.numberOfOutputs
      # FIXME: you want something more like this, see pan~
      #numOutlets = @mainNode.outputs[0].numberOfChannels
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
      # FIXME: has to be a better way...
      for prop, val of @mainNode then do (prop, val) =>
        if val?.input?.index? # is this an AudioletParameter?
          @inlets[val.input.index] = (x) ->
            val.setValue x

  patchosaur.units.add WrappedClass
