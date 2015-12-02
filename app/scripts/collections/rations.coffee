define [
  'underscore'
  'backbone'
  'models/ration'
], (_, Backbone, RationsModel) ->

  class RationsCollection extends Backbone.Collection
    model: RationsModel
    url: () -> 
      "sprints/" + @sprint_id + "/rations"

    initialize: (sprint_id) ->

      if sprint_id
        @sprint_id = sprint_id
      else
        console.log 'Rations without sprint!'

      $.ajaxPrefilter( (options, originalOptions, jqXHR) ->
        options.xhrFields =
          withCredentials: true
        # CORS support
        options.crossDomain =
          crossDomain: true
      )

  return RationsCollection