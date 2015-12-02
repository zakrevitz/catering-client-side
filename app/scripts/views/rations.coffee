define [
  'jquery'
  'underscore'
  'backbone'
  'templates'
  'views/helpers'
], ($, _, Backbone, JST, Helpers) ->
  class RationsView extends Backbone.View
    template: JST['app/scripts/templates/rations.hbs']

    el: '#container'
    events: {}

    initialize: (rations) ->
        @rations = rations

    render: () ->
        @$el.html @template({rations: JSON.parse(@rations)});
