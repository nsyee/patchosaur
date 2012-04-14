express = require 'express'
app = do express.createServer
io = require('socket.io').listen app

controllers = require './app/controllers'
midi = require './app/lib/midi'

cacheMiddleware = (req, res, next) ->
  res.setHeader "Cache-Control", "public, max-age=86400"  # 1 day
  do next


app.configure 'production', ->
  app.use cacheMiddleware

app.use express.static 'public', {maxAge: 86400000} # 1 day
app.configure 'production', ->
  app.use do express.staticCache
app.use express.logger()
app.use express.bodyParser()
app.use express.query()

app.use require('connect-assets')()

app.set 'view engine', 'jade'
app.set 'views', 'app/views'

# routes
app.get  '/',      controllers.index
app.get  '/tests',      controllers.tests
app.get '/patch',  controllers.getPatch
app.post '/patch', controllers.postPatch

# see namespacing
# http://socket.io/#how-to-use
io.sockets.on 'connection', (socket) ->
  midi.input.on 'message', (message) ->
    socket.volatile.emit 'midi', message
    console.log 'midi heard:', message
  socket.emit 'status', message: "connected", status: "SUCCESS"

port = process.env.PORT or 7777
app.listen port
