define [
  'underscore'
  'backbone'
], (_, Backbone) ->
  'use strict';

  class RationModel extends Backbone.Model
    url: '',

    initialize: () ->

    defaults: {}

    validate: (attrs, options) ->

    parse: (response, options) ->
      response
  return RationModel
