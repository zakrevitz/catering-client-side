define [
  'underscore'
  'backbone'
  'models/day'
], (_, Backbone, DayModel) ->

  class DaysCollection extends Backbone.Collection
    url: 'dailymenus'
    model: DayModel