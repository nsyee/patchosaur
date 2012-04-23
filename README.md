# patchosaur

patchosaur is a Max/MSP- and puredata-like patching environment that runs in a browser. It supports audio and MIDI. It's not useful yet, but it can do some cool things.

![demo patchosaur patch](https://github.com/badamson/patchosaur/raw/master/public/img/demo-patch.png)

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

To start a patchosaur server:

```
rake start
```

Now open Chrome and visit [http://localhost:7777](http://localhost:7777)

To start a local patchosaur server in production mode (js and css all concatted and minified):

```
rake start:production
```

To see a list of other tasks:

```
rake -T
```

## Making Patches

Press 'h' to toggle help. Double click to create a new object or to edit an existing one. To connect an inlet to and outlet, click an outlet (it should pulse), then click the inlet. To move an object, drag it.

To remove an object or patchcord:

* On a Mac: alt-click on it
* Linux: ctrl-click on it

### Saving

No real document support. After the app loads, the patch `documents/testDoc.json` is loaded. Every time the patch is edited, it is saved to this file. To edit a new document, replace the contents of `documents/testDoc.json` with `[]`.

### Conventions

* mention right to left (link to some pd or max docs)
  * like pd, not max: trigger is necessary
* mention left inlet is hot with few exceptions (link to puredata docs)
* mention object argument parsing as JSON, commas, valid input

### MIDI

#### Differences from Max and puredata

## Contributing

[Submit an issue](https://github.com/badamson/patchosaur/issues) and/or [fork this](https://github.com/badamson/patchosaur/fork).

### Writing Units

* mention what units are and can do
* mention function inlets, can call outlets, set numInlets and numOutlets on model, reading args

#### Writing function units

#### Writing audiolet units

* mention exposing audiolet inlet and outlet nodes, internal routing

#### Writing audiolet classes

## Up next

* bugs
* more timing objects
* loadbang
* infinite canvas scrolling
* more gui objects (sliders, etc)
* docs
* better MIDI
* static site with bootstrapped document
* unit tests
* demo video

## Future Ideas

* Document support, save and share patches:
  * stored remotely (save and load to/from github pritave anonymous gists or dropbox or something), would be nice for purely static server-less app
  * stored locally, checked into repo (nice for demo patches at least)
  * localStorage or load and save from copypastad text
  * have the app access a database, not sure I like this idea
* Static site generation with `wget --mirror`, hosted on gh-pages, so anyone can try it out.
* Max-like subpatcher and abstraction support
* Collaborative patch editing (send model changes over socket.io)
* Undo support (backbone.memento?), would be nice if it worked with browser back button
* Easy patchosaur units in faust would be awesome. [faust](http://faust.grame.fr/) compiles to js, maybe add audiolet architecture files to faust? See [this article](http://faust.grame.fr/index.php/7-news/73-faust-web-art).
