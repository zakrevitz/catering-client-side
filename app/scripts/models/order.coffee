define [
  'underscore'
  'backbone'
], (_, Backbone) ->
  'use strict';

  class OrderModel extends Backbone.Model
    url: 'daily_ration',

    initialize: () ->

    defaults: {}

    validate: (attrs, options) ->

    parse: (response, options) ->
      response
  # return new OrderModel()