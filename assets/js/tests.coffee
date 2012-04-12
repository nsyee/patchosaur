#= require patchagogy
#= require 3p/jasmine
#= require 3p/jasmine-html
#= require_tree spec

console.log('loaded tests')

jasmineEnv = do jasmine.getEnv
jasmineEnv.updateInterval = 1000

trivialReporter = new jasmine.TrivialReporter

jasmineEnv.addReporter trivialReporter

jasmineEnv.specFilter (spec) ->
  trivialReporter.specFilter spec

currentWindowOnload = window.onload

window.onload = ->
  do currentWindowOnload if currentWindowOnload
  do jasmineEnv.execute
