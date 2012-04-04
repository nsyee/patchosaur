#= require 3p/jquery
#= require 3p/bootstrap
#= require 3p/underscore
#= require 3p/raphael
#= require 3p/backbone
#= require 3p/audiolet
#= require draw/connection
#= require models
#= require views
#= require routes
#= require_tree units

$ ->
  # start the engines
  appController = new patchagogy.controllers.App
  do Backbone.history.start
  console.log 'aww... shit.'
