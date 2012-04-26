# patchosaur

patchosaur is a [Max/MSP](http://en.wikipedia.org/wiki/Max_\(software\))- and [puredata](http://en.wikipedia.org/wiki/Pure_Data)-like patching environment that runs in a browser. It supports audio and MIDI. All of the audio is synthesized in real time in javascript by [audiolet](https://github.com/oampo/Audiolet). It's a buggy work in progress and not usable yet, but it can do some cool things.

* on github: https://github.com/badamson/patchosaur/
* http://patchosaur.org
* demo video: http://www.youtube.com/watch?v=V7c3XwabUKM
* [On Create Digital Music](http://createdigitalmusic.com/2012/04/patchosaur-audio-midi-and-maxpd-style-patching-in-a-browser-because-you-can/)

![demo patchosaur patch](https://github.com/badamson/patchosaur/raw/master/public/img/demo-patch.png)

<iframe id="ytplayer" type="text/html" width="640" height="390" src="http://www.youtube.com/embed/V7c3XwabUKM" frameborder="0"/>

## Installing dependencies to run locally

### Install [node.js](http://nodejs.org/), git, dependencies

*  Mac
  * Install [homebrew](http://mxcl.github.com/homebrew/)
  * Install node and git `brew install node git`
  * Install [npm](http://npmjs.org/): `curl http://npmjs.org/install.sh | sh`
  * ??? Install [rubygems](http://rubygems.org/)
  * Install rake: `gem install rake`

* Ubuntu
  * Install gcc, git, alsa headers: `sudo apt-get install build-essentials git libasound2-dev`
  * Install [node.js](http://nodejs.org/) from source, which I think comes with [npm](http://npmjs.org/).
  * ??? Install [rubygems](http://rubygems.org/)
  * Install rake: `gem install rake`

### Check out patchosaur

Do one of the following:

  * clone mine: `git clone git@github.com:badamson/patchosaur.git`
  * [fork it](https://github.com/badamson/patchosaur/fork) and clone that

Install patchosaur's node.js dependencies:

```
cd patchosaur
npm update # install or update node.js dependencies from package.json
```

### Run it

To start a patchosaur server:

```
rake start
```

Now open Chrome and visit [http://localhost:7777](http://localhost:7777). It might work in Firefox, haven't tried.

To start a local patchosaur server in production mode (js and css all concatted and minified):

```
rake start:production
```

To see a list of other tasks:

```
rake -T
```

## Making Patches

Press 'h' to toggle help. Double click to create a new object or to edit an existing one. To connect an inlet to and outlet, click an outlet (it should pulse), then click the inlet. To move an object, drag it. To create a comment, create an object starting with `c`, like `c "this is a comment"`.

To remove an object or patchcord:

* On a Mac: alt-click on it
* Linux: ctrl-click on it

### Saving

No real document support. After the app loads, the patch `documents/testDoc.json` is loaded. Every time the patch is edited, it is saved to this file. To edit a new document, replace the contents of `documents/testDoc.json` with `[]`. To "save," move the file.

### Audio objects (~ suffix)

Units that have audio inputs or outputs have a tilde suffix (`*~`, `cycle~`). Some of them do not work yet (any with multiple outputs, buffer stuff, callbacks). Most of them are directly wrapped from Audiolet. See the sections "DSP" and "Operators" in the [Audiolet API Documentation](http://oampo.github.com/Audiolet/api.html) for argument and inlet specifications.

For example, in the Audiolet API Documentation, under "DSP", the Lag constructor takes 3 arguments: audiolet, initial value (default 0), and lag time (default 1). The first argument, audiolet, is passed for you. Arguments (initial value, lag time) can be optionally passed as patchosaur arguments: `lag~ 0.5, 0.1`. The inputs in the documentation are value and lag time. You can make patchcord connections to audio inputs from audio outputs, and to audiolet parameters from function inputs.

### Conventions

* object outlets are always called in right to left order, depth first, exactly as in Max or PD.
  * see [Max docs](http://cycling74.com/docs/max5/tutorials/max-tut/basicchapter05.html)
  * see [PD docs](http://crca.ucsd.edu/~msp/Pd_documentation/x2.htm)
* The leftmost inlet is "hot", other inlets do not result in output (with a few exceptions)
* Unlike PD or Max which have space-delimited object arguments, in patchosaur everything after the first space is surrounded by square brackets and parsed as JSON.
  * `route "ten", 11, 12` will instantiate a `route` unit with arguments `["ten", 11, 12]`
  * `route "ten" 11 12` fails to parse
* When a single object outlet is connected to multiple inlets, Max always works right to left. In PD, this isn't the case; you always need a `trigger` or something to guarantee order. Patchosaur works like PD in this regard.
  * That said, `trigger` (or `t` for short) is different from its Max/PD cousins. It is meant only for message ordering, and takes one argument: the number of outlets. It repeats whatever it receives right-to-left from every outlet.
  * `dump` (or `d`) is similar to trigger, but outputs its arguments in right-to-left order whenever it receives any message. `dump true, 4, "hey there"` will have 3 outlets, and when it hears any message in its inlet, will output "hey there" from outlet 2, then 4 from outlet 1, then true from outlet 0.
* `switch`, `route`, `gate` should be identical to Max's.
* A lot of basic Max/pd stuff is missing, but you can use the `cs` unit to define useful objects as coffeescript functions. The number of inlets is the number of arguments the function takes, there is always a single outlet, and the function isn't invoked until it hears something in the "hot" left inlet. `cs "(x, y) -> x + y"` should be identical to `+`. The function argument to `cs` is bound to a new empty object, so you can use `this` to remember stuff: `cs "(b) -> @x = (@x or 0) + 1"` is a basic counter.

### MIDI

MIDI travels over websockets from the patchosaur server. See the `socket.io` unit. This is just a proof of concept for now, but seems to work fine for input.

## Contributing

Play with it, [submit an issue](https://github.com/badamson/patchosaur/issues), [fork it](https://github.com/badamson/patchosaur/fork).

### Writing Units

Units are little programs that can be connected by patchcords. They are all defined [here](https://github.com/badamson/patchosaur/tree/master/assets/js/units), where there are many examples. To add a unit, define a class in the units directory that extends `patchosaur.Unit`, add a `setup` method, and then register it: `patchosaur.units.add MyUnit`.

Units can change model attributes during setup, which will be reflected in the ui view:

* Set the number of inlets: `@objectModel.set numInlets: 3`
* Set the number of outlets: `@objectModel.set numOutlets: 3`
* Set an error (will make the object red in the ui view), which you should also log (`console.error anError`): `@objectModel.set error: "I've made a huge mistake."`
* Set the id of a custom gui (unit adds this to the dom for now, moved and removed by ui view, see [gui units](https://github.com/badamson/patchosaur/tree/master/assets/js/units/gui)): `@objectModel.set customGuiId: id`

They can also expose attributes that do stuff:

* `@inlets = [inletFunc1, inletFunc2]`: an array of functions to be called when something is connected to one of the unit's inlets (mapped by index).
* audiolet nodes to be connected and disconnected (see [audio units](https://github.com/badamson/patchosaur/tree/master/assets/js/units/audio)):
  * `@audioletOutputNodes = [audioletNode1, audioletNode2]`
  * `@audioletInputNodes = [audioletNode1, audioletNode2]`

They should name themselves in a class variable (see [examples](https://github.com/badamson/patchosaur/blob/master/assets/js/units), `@names = ['spigot', 'gate']`).They can read arguments from the model (`@objectModel.get 'unitArgs'`), which is an array. When an object is created, everything before the first space is set as `unitClass`, which is used to look up a unit by name, and everything after is surrounded by square brackets and parsed as JSON. `route 1, 4, 5`'s args become [1, 4, 5], while `route 1 4 5` fails to parse.

#### Documenting units

In addition to setting `names` as a class variable, units can set `tags` and `help`. This doesn't do anything yet, but in the future it will show in help (press 'h' to show, right now just displays a list of units).

#### Writing custom audiolet nodes

* FIXME: write some in coffeescript as examples. SuperCollider's [Leaky Integrator](http://www.ambisonictoolkit.net/Help/Classes/Integrator.html) would be nice to have. [This list of SC3 classes](http://www.ambisonictoolkit.net/Help/Overviews/Classes.html) has a lot of cool stuff.

## Up next

* bugs
* [make it puredata compatible](https://github.com/badamson/patchosaur/issues/6)
* perfomance
* config
* more [control objects](http://cycling74.com/docs/max5/vignettes/thesaurus/thesaurus.html)
* more timing objects
* bang, loadbang
* better help (right now it just displays a list of units)
* more gui objects (number object like Max would be cool)
* docs
* better MIDI, including output
* static site with bootstrapped document (see `rake statify` task, which works except for ajax doc load)
  * deploy to `patchosaur.org/demo` or something
* unit tests
* demo video
* infinite canvas scrolling (maybe click drag, and just move all the objects?)
* recording support: https://github.com/oampo/Audiolet/issues/11#issuecomment-2716776

## Future Ideas

* Document support, save and share patches:
  * stored remotely (save and load to/from github pritave anonymous gists or [google drive](http://code.google.com/p/google-api-javascript-client/wiki/Samples#Drive_API) or something), would be nice for purely static server-less app
  * filesystem, checked into repo (nice for example patches at least)
  * localStorage or load and save from copypastad text
  * have the app access a database, not sure I like this idea
* Static site generation with `wget --mirror`, hosted on gh-pages, so anyone can try it out.
* Max-like subpatcher and abstraction support
* Collaborative patch editing (send model changes over socket.io)
* Undo support (backbone.memento?), would be nice if it worked with browser back button
* Easy patchosaur units in faust would be awesome. [faust](http://faust.grame.fr/) compiles to js, maybe add audiolet architecture files to faust? See [this article](http://faust.grame.fr/index.php/7-news/73-faust-web-art).

## List of current units

Many of these are not working, and the list is probably out of date. The list is copied from the in-app help (press 'h')

* `cycle~`
* `triangle~`
* `saw~`
* `square~`
* `pulse~`
* `noise~`
* `envelope~`
* `adsr~`
* `perc~`
* `bufferplayer~`
* `gain~`
* `pan~`
* `upmixer~`
* `xfade~`
* `linerxfade~`
* `limiter~`
* `biquad~`
* `lpf~`
* `hpf~`
* `bpf~`
* `brf~`
* `apf~`
* `dcblock~`
* `lag~`
* `delay~`
* `fbdelay~`
* `comb~`
* `dampcomb~`
* `reverb~`
* `reverbb~`
* `softclip~`
* `bitcrusher~`
* `amp~`
* `discontinuity~`
* `badvalue~`
* `triggercontrol~`
* `add~`
* `+~`
* `subtract~`
* `-~`
* `multiply~`
* `*~`
* `divide~`
* `/~`
* `modulo~`
* `%~`
* `reciprocal~`
* `muladd~`
* `*+~`
* `tanh~`
* `bdpercsynth~`
* `snarepercsynth~`
* `chpercsynth~`
* `dac~`
* `out~`
* `cs`
* `dump`
* `d`
* `gate`
* `spigot`
* `identity`
* `makenote`
* `cos`
* `random`
* `pow`
* `tan`
* `atan2`
* `floor`
* `log`
* `abs`
* `min`
* `max`
* `ceil`
* `asin`
* `exp`
* `sqrt`
* `atan`
* `sin`
* `round`
* `acos`
* `+`
* `-`
* `/`
* `*`
* `%`
* `&`
* `|`
* `^`
* `~`
* `<<`
* `>>`
* `>>>`
* `==`
* `!=`
* `>`
* `<`
* `>=`
* `<=`
* `&&`
* `and`
* `||`
* `or`
* `!`
* `not`
* `log2`
* `log10`
* `atodb`
* `dbtoa`
* `mtof`
* `ftom`
* `rtanh`
* `metro`
* `metrolite`
* `monovoicer`
* `null`
* `parsenote`
* `print`
* `route`
* `socket.io`
* `switch`
* `trigger`
* `t`
* `checkbox`
* `cb`
* `range`
