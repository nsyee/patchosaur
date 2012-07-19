exec = require('child_process').exec


task 'test', 'run vows tests and coffeelint', -> coffeelint()
task 'coffeelint', 'run coffeelint', -> coffeelint()
coffeelint = ->
  _exec "find assets app -name '*.coffee' | xargs node_modules/.bin/coffeelint -f etc/coffeelint.json"


task 'fixme', 'fixme_command', ->
  _exec "grep -ri --after-context=5 fixme assets app"


task 'start', 'start the server', ->
  _exec "./node_modules/.bin/coffee server.coffee"


task 'start:production', 'start the server in production mode', ->
  _exec "export NODE_ENV=production; ./node_modules/.bin/coffee server.coffee"


task 'checkout:documents', 'git checkout documents', ->
  _exec "git checkout documents"


# see
# http://www.noah.org/wiki/Offline_mirror_with_wget
# http://news.ycombinator.com/item?id=3196103
task 'statify', 'generate static site from app running locally on port 7777; run rake start:production first', ->
  _exec "wget --mirror --page-requisites --no-host-directories --directory-prefix=static --convert-links localhost:7777"


task 'update3p', 'update 3p', ->
  parallel [
    (next) -> curl('assets/js/3p/underscore.js','https://raw.github.com/documentcloud/underscore/master/underscore.js', next),
    (next) -> curl('assets/js/3p/state-machine.js','https://raw.github.com/jakesgordon/javascript-state-machine/master/state-machine.js',next),
    (next) -> curl('assets/js/3p/raphael.js','https://raw.github.com/DmitryBaranovskiy/raphael/master/raphael.js',next),
    (next) -> curl('assets/js/3p/audiolet.js','https://raw.github.com/oampo/Audiolet/master/src/audiolet/Audiolet.js',next),
    (next) -> curl('assets/js/3p/backbone.js','http://documentcloud.github.com/backbone/backbone.js',next),
    (next) -> curl('assets/js/3p/jquery.js','http://code.jquery.com/jquery-1.7.1.js',next),
    (next) -> curl('assets/js/3p/coffee-script.js','https://raw.github.com/jashkenas/coffee-script/master/extras/coffee-script.js',next),
    (next) -> curl('assets/js/3p/jasmine.js','https://raw.github.com/pivotal/jasmine/master/lib/jasmine-core/jasmine.js',next),
    (next) -> curl('assets/js/3p/jasmine-html.js','https://raw.github.com/pivotal/jasmine/master/lib/jasmine-core/jasmine-html.js',next),
    (next) -> curl('assets/css/3p/jasmine.css','https://raw.github.com/pivotal/jasmine/master/lib/jasmine-core/jasmine.css',next)
  ], ->
    # get bootstrap
    # FIXME: clean up
    serial [
      (next) -> _exec "mkdir -p 'tmp_bootstrap'",next
      (next) -> curl('tmp_bootstrap/bootstrap.zip','http://twitter.github.com/bootstrap/assets/bootstrap.zip',next),
      (next) -> _exec "unzip -d tmp_bootstrap tmp_bootstrap/bootstrap.zip",next
      (next) -> _exec "cp tmp_bootstrap/bootstrap/css/*min*.css assets/css/3p/",next
      (next) -> _exec "cp tmp_bootstrap/bootstrap/js/*min*.js assets/js/3p/",next
      (next) -> _exec "cp tmp_bootstrap/bootstrap/img/* public/img",next
      #FIXME: Include images
      (next) -> _exec "rm -r tmp_bootstrap",next
      # strip 'min' out of all names
      (next) -> _exec "bash -c 'for file in `find assets -name \'*.min.*\'`; do mv $file ${file/\.min\./\.}; done;\'",next
    ], -> console.log("done.")



# exec system command
_exec = (cmd, next) ->
  exec cmd, (err, stdout, stderr) ->
    console.log(cmd)
    console.log(stdout) if stdout
    console.log(stderr) if stderr
    next() if typeof next is "function"


# curl wrapper
curl = (target, url, next) ->
  _exec "curl -o #{target} '#{url}'", next


# exec tasks in parallel
parallel = (tasks, callback) ->
  counter = tasks.length
  next = ->
    if --counter is 0
      callback()
  for task in tasks
    task(next)


# exec tasks in serial
serial = (tasks, cb) ->
  recur = (i, len) ->
    if i >= len
      return cb()
    tasks[i] (error) ->
      if error
        return cb(error)
      recur(i + 1, len)
  recur(0, tasks.length)
