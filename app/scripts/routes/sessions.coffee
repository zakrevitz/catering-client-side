define [
  'backbone'
], (Backbone) ->
  class CateringRouter extends Backbone.Router
    routes:
      "" : "index"
      "login": "login"
      "sprints": "sprints"
      "history": "history"