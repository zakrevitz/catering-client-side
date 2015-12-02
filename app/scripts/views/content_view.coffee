define [
  'jquery'
  'underscore'
  'backbone'
  'templates'
], ($, _, Backbone, JST) ->
  class ContentView extends Backbone.View
    switchView: (view) ->
      if this.currentView
        if this.currentView.close
          this.currentView.close()
        this.currentView.remove()
        this.currentView = null
      this.currentView = view
      $('body').append(this.currentView.el)
      this.currentView.render()
      return
  return new ContentView()