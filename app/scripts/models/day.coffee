define [
  'underscore'
  'backbone'
], (_, Backbone) ->
  'use strict';

  class DayModel extends Backbone.Model
    url: 'dailymenus',

    initialize: () ->
      $.ajaxSetup({
        'beforeSend': (xhr) ->
          xhr.setRequestHeader("accept", "application/json");
      })

      $.ajaxPrefilter( (options, originalOptions, jqXHR) ->
        options.xhrFields =
          withCredentials: true
        options.crossDomain =
          crossDomain: true
      )

    defaults: {}

    validate: (attrs, options) ->

    parse: (response, options) ->
      response