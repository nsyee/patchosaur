# patchagogy

Patchagogy is...

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

### Check out patchagogy

Do one of the following:

  * clone mine: `git clone git@github.com:badamson/patchagogy.git`
  * [fork it](https://github.com/badamson/patchagogy/fork) and clone that

Install patchagogy's node.js dependencies:

```
cd patchagogy
npm update # install or update node.js dependencies from package.json
```

To start a patchagogy server:

```
rake start
```

Now open Chrome and visit [http://localhost:7777](http://localhost:7777)

To start a local patchagogy server in production mode (js and css all concatted and minified):

```
rake start:production
```

To see a list of other tasks:

```
rake -T
```

## Making Patches

### Conventions

* mention right to left (link to some pd or max docs)
  * like pd, not max: trigger is necessary
* mention left inlet is hot with few exceptions (puredata docs)
* object argument parsing as JSON, commas, valid input

#### Differences from Max and puredata

## Contributing

[Submit an issue](https://github.com/badamson/patchagogy/issues) and/or [fork this](https://github.com/badamson/patchagogy/fork) if you want to help!

### Arch

Models, units, unit graph views, ui views

### Writing Units

* mention what units are and can do
* mention function inlets, can call outlets, set numInlets and numOutlets on model, reading args

#### Writing function units

#### Writing audiolet units

* mention exposing audiolet inlet and outlet nodes, internal routing, they don't even work yet.

### Future Ideas

* Document support: save and share patches
  * stored remotely (save and load to/from github pritave anonymous gists or dropbox or something), would be nice for purely static server-less app
  * stored locally, checked into repo (nice for demo patches at least)
  * localStorage or load and save from copypastad text
* Max-like subpatcher and abstraction support
* Collaborative patch editing (send model changes over socket.io)
