fs = require 'fs'

exports.index = (request, response, next) ->
  response.render 'index', {}

exports.postPatch = (request, response, next) ->
  doc = JSON.stringify request.body, null, 2
  fs.writeFile 'documents/testDoc.json', doc, (error) ->
    if error
      response.json error, 500
    else
      response.json
        status: 'SUCCESS'
      , 200

exports.getPatch = (request, response, next) ->
  fs.readFile 'documents/testDoc.json', (error, data) ->
    if error
      response.json error, 500
    else
      response.send data
