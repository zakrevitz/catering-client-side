define [
  'underscore'
  'backbone'
], (_, Backbone) ->
  'use strict';

  class SprintModel extends Backbone.Model
    url: 'sprints',

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

    parse: (response, options) ->
       response

    getSprint:  ->
      this.fetch(
        success: (model, xhr, response) ->
          console.log "WUT A PURRRRFECT AYAKZ!", model
        error: ->
          console.log "NO WUAY ITZ IMPUSIBRU!!!!" 
      )