#/*global require*/
'use strict'

require.config
  shim: {
    bootstrap:
      deps: ['jquery'],
      exports: 'jquery'
    handlebars:
      exports: 'Handlebars'
  }
  paths:
    jquery: '../bower_components/jquery/dist/jquery'
    jquery_ui: '../bower_components/jquery-ui/jquery-ui'
    backbone: '../bower_components/backbone/backbone'
    underscore: '../bower_components/lodash/dist/lodash'
    bootstrap: '../bower_components/bootstrap-sass-official/assets/javascripts/bootstrap'
    handlebars: '../bower_components/handlebars/handlebars'
    notify: '../bower_components/notify/index'
    router: 'routes/sessions'
    app: 'app'


require [
  'backbone',
  'app'
], (Backbone, App) ->
  App.initialize()